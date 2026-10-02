import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:datahub/telemetry.dart' show SpanType;

import '../abstract/redis_commands.dart';
import '../abstract/redis_connection.dart';
import '../abstract/redis_exception.dart';
import '../abstract/redis_reply.dart';
import '../abstract/redis_transaction.dart';
import '../redis_telemetry.dart';
import 'command_rules.dart';
import 'queued_transaction.dart';
import 'resp_encoder.dart';
import 'resp_parser.dart';
import 'scan.dart';

/// A RESP2 connection to a Redis server over TCP (optionally TLS).
///
/// Commands are written as soon as they are sent (coalesced per microtask)
/// and replies are matched to commands in order, so any number of commands
/// can be in flight at the same time.
///
/// The connection closes itself on any I/O error, protocol violation or
/// command timeout and fails all pending commands, since the reply stream
/// cannot be matched to commands anymore after any of those. [isOpen]
/// reflects this immediately.
class RedisSocketConnection with RedisCommands implements RedisConnection {
  static final _multi = RespEncoder.encode(const ['MULTI']);
  static final _exec = RespEncoder.encode(const ['EXEC']);

  final Socket _socket;

  /// Default timeout for commands, null means no timeout.
  final Duration? commandTimeout;

  final RedisTelemetry _telemetry;

  final _parser = RespParser();
  final _pending = ListQueue<_PendingReply>();
  final _writeBuffer = BytesBuilder(copy: false);
  var _flushScheduled = false;

  final _closed = Completer<void>();
  RedisConnectionException? _closeReason;

  /// Time since the last write or read.
  final _idle = Stopwatch()..start();

  void Function(RedisReply reply)? _pushHandler;

  final int _initialDatabase;
  int _database;
  var _watching = false;
  var _inMulti = false;
  var _tainted = false;

  RedisSocketConnection._(
    this._socket, {
    required this.commandTimeout,
    required int database,
    required RedisTelemetry telemetry,
  }) : _telemetry = telemetry,
       _initialDatabase = database,
       _database = database {
    _socket.listen(
      _onData,
      onError: (Object error) =>
          _fail(RedisConnectionException('Connection error.', error)),
      onDone: () => _fail(
        const RedisConnectionException('Connection closed by server.'),
        kind: 'server',
      ),
      cancelOnError: true,
    );
    // write errors are only reported through done
    _socket.done.then<void>(
      (_) {},
      onError: (Object error) =>
          _fail(RedisConnectionException('Connection error.', error)),
    );
  }

  /// Opens a connection to [host]:[port] and authenticates it.
  ///
  /// [connectTimeout] limits the whole connection setup including the TLS
  /// handshake and the initial commands (`AUTH`, `CLIENT SETNAME`,
  /// `SELECT`). Authentication uses [password] with [username] (Redis 6 ACL)
  /// or with the default user if [username] is null, and is skipped if
  /// [password] is null.
  static Future<RedisSocketConnection> connect({
    required String host,
    required int port,
    bool useTls = false,
    SecurityContext? securityContext,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration? commandTimeout = const Duration(seconds: 10),
    String? username,
    String? password,
    int database = 0,
    String? clientName,
    RedisTelemetry telemetry = RedisTelemetry.disabled,
  }) => telemetry.traced(
    'Redis Connect',
    () async {
      try {
        return await _connect(
          host: host,
          port: port,
          useTls: useTls,
          securityContext: securityContext,
          connectTimeout: connectTimeout,
          commandTimeout: commandTimeout,
          username: username,
          password: password,
          database: database,
          clientName: clientName,
          telemetry: telemetry,
        );
      } catch (e) {
        telemetry.error(e);
        rethrow;
      }
    },
    type: SpanType.client,
    attributes: {
      'db.system.name': 'redis',
      'db.namespace': database.toString(),
      'server.address': host,
      'server.port': port,
      'network.transport': 'tcp',
      if (useTls) 'tls.enabled': true,
    },
  );

  static Future<RedisSocketConnection> _connect({
    required String host,
    required int port,
    required bool useTls,
    required SecurityContext? securityContext,
    required Duration connectTimeout,
    required Duration? commandTimeout,
    required String? username,
    required String? password,
    required int database,
    required String? clientName,
    required RedisTelemetry telemetry,
  }) async {
    final watch = Stopwatch()..start();
    Duration remaining() {
      final remaining = connectTimeout - watch.elapsed;
      return remaining.isNegative ? Duration.zero : remaining;
    }

    Socket socket;
    try {
      socket = await Socket.connect(host, port, timeout: connectTimeout);
    } on SocketException catch (e) {
      throw RedisConnectionException('Could not connect to $host:$port.', e);
    }

    if (useTls) {
      final plain = socket;
      try {
        // the timeout of SecureSocket.connect only covers TCP, a server that
        // does not speak TLS would stall the handshake forever
        socket = await SecureSocket.secure(
          plain,
          host: host,
          context: securityContext,
        ).timeout(remaining());
      } catch (e) {
        plain.destroy();
        throw RedisConnectionException(
          'TLS handshake with $host:$port failed.',
          e,
        );
      }
    }

    try {
      socket.setOption(SocketOption.tcpNoDelay, true);
    } catch (_) {
      // not supported by all socket types
    }

    final connection = RedisSocketConnection._(
      socket,
      commandTimeout: commandTimeout,
      database: database,
      telemetry: telemetry,
    );

    try {
      await connection._handshake(
        username: username,
        password: password,
        clientName: clientName,
        timeout: remaining(),
      );
    } on TimeoutException catch (e) {
      await connection.close();
      throw RedisConnectionException(
        'Connection setup with $host:$port timed out.',
        e,
      );
    } catch (_) {
      await connection.close();
      rethrow;
    }

    telemetry.connectionOpened();
    return connection;
  }

  /// Sends the initial commands in a single round trip.
  Future<void> _handshake({
    required String? username,
    required String? password,
    required String? clientName,
    required Duration timeout,
  }) async {
    final auth = password == null
        ? null
        : _request(RespEncoder.encode(['AUTH', ?username, password]), timeout);
    final setName = clientName == null
        ? null
        : _request(
            RespEncoder.encode(['CLIENT', 'SETNAME', clientName]),
            timeout,
          );
    final select = _initialDatabase == 0
        ? null
        : _request(RespEncoder.encode(['SELECT', _initialDatabase]), timeout);

    final replies = await Future.wait([?auth, ?setName, ?select]);
    var index = 0;
    if (auth != null) {
      if (replies[index++] case RedisErrorReply error) {
        throw error.toException();
      }
    }
    if (setName != null) {
      // not supported by some proxies, the name is only informational
      index++;
    }
    if (select != null) {
      if (replies[index++] case RedisErrorReply error) {
        throw error.toException();
      }
    }
  }

  @override
  bool get isOpen => _closeReason == null;

  /// Completes when the connection is closed.
  Future<void> get closed => _closed.future;

  /// Time since data was last written to or received from the server.
  Duration get idleTime => _idle.elapsed;

  /// Number of commands waiting for their reply.
  int get pendingCount => _pending.length;

  @override
  Future<T> sendCommand<T>(
    List<Object> command,
    T Function(RedisReply reply) decode, {
    Duration? timeout,
  }) async {
    final name = commandName(command);
    checkSupportedCommand(name, command);
    return _telemetry.command(
      name,
      _database,
      () => _send(name, command, decode, timeout),
    );
  }

  /// Like [sendCommand] for commands issued by the connection management
  /// (health checks, state reset), which are not reported as commands.
  Future<T> sendInternalCommand<T>(
    List<Object> command,
    T Function(RedisReply reply) decode, {
    Duration? timeout,
  }) async {
    final name = commandName(command);
    checkSupportedCommand(name, command);
    return _send(name, command, decode, timeout);
  }

  Future<T> _send<T>(
    String? name,
    List<Object> command,
    T Function(RedisReply reply) decode,
    Duration? timeout,
  ) async {
    final reply = await _request(
      RespEncoder.encode(command),
      timeout ?? commandTimeout,
    );
    _track(name, command, reply);

    if (reply is RedisErrorReply) {
      throw reply.toException();
    }
    return decode(reply);
  }

  @override
  Future<void> watch(Iterable<String> keys) =>
      sendCommand(['WATCH', ...keys], (_) {});

  @override
  Future<void> unwatch() => sendCommand(['UNWATCH'], (_) {});

  @override
  Future<bool> transaction(void Function(RedisTransaction tx) commands) async {
    final transaction = QueuedTransaction();
    try {
      commands(transaction);
    } catch (e, stack) {
      transaction
        ..seal()
        ..failAll(e, stack);
      rethrow;
    }
    transaction.seal();

    if (transaction.changesState) {
      _tainted = true;
    }

    final queued = transaction.commands;
    return _telemetry.transaction(
      _database,
      queued.length,
      () => _runTransaction(transaction, queued),
    );
  }

  Future<bool> _runTransaction(
    QueuedTransaction transaction,
    List<QueuedCommand> queued,
  ) async {
    // MULTI, all commands and EXEC are written in one synchronous step, so
    // nothing else can be interleaved on this connection
    _inMulti = true;
    final List<RedisReply> replies;
    try {
      replies = await Future.wait([
        _request(_multi, commandTimeout),
        for (final command in queued) _request(command.encoded, commandTimeout),
        _request(_exec, commandTimeout),
      ]);
    } catch (e, stack) {
      transaction.failAll(e, stack);
      rethrow;
    } finally {
      _inMulti = false;
      _watching = false;
    }

    if (replies.first case RedisErrorReply error) {
      // a MULTI that was sent with execute() before is still open, so the
      // commands were added to that transaction instead
      _tainted = true;
      final exception = error.toException();
      transaction.failAll(exception);
      throw exception;
    }

    switch (replies.last) {
      case RedisArray(:final items) when items.length == queued.length:
        for (var i = 0; i < queued.length; i++) {
          queued[i].complete(items[i]);
        }
        return true;

      case RedisNull():
        transaction.failAll(const RedisTransactionAbortedException());
        return false;

      case RedisErrorReply error:
        // EXECABORT: nothing was executed, report why each command failed
        final exception = error.toException();
        for (var i = 0; i < queued.length; i++) {
          if (replies[i + 1] case RedisErrorReply queueError) {
            queued[i].fail(queueError.toException());
          } else {
            queued[i].fail(exception);
          }
        }
        throw exception;

      case final reply:
        final exception = RedisConnectionException(
          'Unexpected reply to EXEC: $reply',
        );
        _fail(exception);
        transaction.failAll(exception);
        throw exception;
    }
  }

  @override
  Stream<String> scan({String? match, int? count, String? type}) =>
      scanKeys(this, match: match, count: count, type: type);

  /// Restores the connection state that was changed by commands since the
  /// connection was opened (open transaction, watched keys, selected
  /// database).
  ///
  /// Closes the connection if its state cannot be restored (for example
  /// after `AUTH`).
  Future<void> reset() async {
    if (!isOpen) {
      return;
    }
    if (_tainted) {
      await close();
      return;
    }
    if (_inMulti) {
      await sendInternalCommand(['DISCARD'], (_) {});
    } else if (_watching) {
      await sendInternalCommand(['UNWATCH'], (_) {});
    }
    if (_database != _initialDatabase) {
      await sendInternalCommand(['SELECT', _initialDatabase], (_) {});
    }
  }

  /// Switches the connection into subscriber mode.
  ///
  /// All further replies are passed to [handler] instead of being matched to
  /// commands, and commands are sent using [write].
  void enterSubscriberMode(void Function(RedisReply reply) handler) {
    if (_pending.isNotEmpty) {
      throw StateError('Connection has pending commands.');
    }
    _pushHandler = handler;
  }

  /// Writes [command] without waiting for a reply (subscriber mode).
  void write(List<Object> command) {
    if (isOpen) {
      _write(RespEncoder.encode(command));
    }
  }

  /// Closes the connection and fails all pending commands.
  Future<void> close() async {
    _fail(const RedisConnectionException('Connection closed.'), kind: 'local');
  }

  Future<RedisReply> _request(Uint8List request, Duration? timeout) {
    if (_closeReason case final reason?) {
      return Future.error(reason);
    }
    if (_pushHandler != null) {
      return Future.error(StateError('Connection is in subscriber mode.'));
    }

    final pending = _PendingReply();
    _pending.add(pending);
    _write(request);

    if (timeout != null) {
      pending.timer = Timer(timeout, () {
        // the reply could still arrive and would then be taken for the reply
        // of the next command
        _fail(
          const RedisConnectionException(
            'Connection closed after a command timed out.',
          ),
          kind: 'timeout',
          timedOut: pending,
          timeoutError: TimeoutException(
            'Redis command timed out after $timeout.',
            timeout,
          ),
        );
      });
    }

    return pending.completer.future;
  }

  void _write(Uint8List bytes) {
    _idle.reset();
    _writeBuffer.add(bytes);
    if (!_flushScheduled) {
      _flushScheduled = true;
      scheduleMicrotask(_flush);
    }
  }

  void _flush() {
    _flushScheduled = false;
    if (!isOpen || _writeBuffer.isEmpty) {
      return;
    }
    try {
      _socket.add(_writeBuffer.takeBytes());
    } catch (e) {
      _fail(RedisConnectionException('Could not write to connection.', e));
    }
  }

  void _onData(Uint8List chunk) {
    _idle.reset();
    _parser.add(chunk);
    try {
      while (isOpen) {
        final reply = _parser.next();
        if (reply == null) {
          break;
        }

        if (_pushHandler case final handler?) {
          handler(reply);
        } else if (_pending.isEmpty) {
          throw const RespProtocolException(
            'Received a reply without a pending command.',
          );
        } else {
          final pending = _pending.removeFirst();
          pending.timer?.cancel();
          pending.completer.complete(reply);
        }
      }
    } on RespProtocolException catch (e) {
      _fail(RedisConnectionException('Protocol error.', e));
    }
  }

  void _fail(
    RedisConnectionException reason, {
    String? kind,
    _PendingReply? timedOut,
    Object? timeoutError,
  }) {
    if (_closeReason != null) {
      return;
    }
    _closeReason = reason;
    _telemetry.connectionClosed(
      kind ?? (reason.cause is RespProtocolException ? 'protocol' : 'error'),
    );
    _writeBuffer.clear();
    _socket.destroy();

    final pending = List.of(_pending);
    _pending.clear();
    for (final reply in pending) {
      reply.timer?.cancel();
      reply.completer.completeError(
        identical(reply, timedOut) ? timeoutError! : reason,
      );
    }

    _closed.complete();
  }

  /// Keeps track of connection state changed by [command], see [reset].
  void _track(String? name, List<Object> command, RedisReply reply) {
    final success = reply is! RedisErrorReply;
    switch (name) {
      case 'EXEC' || 'DISCARD':
        _inMulti = false;
        _watching = false;
      case 'MULTI' when success:
        _inMulti = true;
      case _ when _inMulti:
        // queued commands only take effect on EXEC
        if (success && changesConnectionState(name)) {
          _tainted = true;
        }
      case 'WATCH' when success:
        _watching = true;
      case 'UNWATCH' when success:
        _watching = false;
      case 'SELECT' when success:
        final database = int.tryParse(command[1].toString());
        if (database == null) {
          _tainted = true;
        } else {
          _database = database;
        }
      case 'AUTH' || 'SWAPDB' when success:
        _tainted = true;
    }
  }
}

class _PendingReply {
  final completer = Completer<RedisReply>();
  Timer? timer;
}
