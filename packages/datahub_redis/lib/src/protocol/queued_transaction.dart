import 'dart:async';
import 'dart:typed_data';

import '../abstract/redis_commands.dart';
import '../abstract/redis_reply.dart';
import '../abstract/redis_script.dart';
import '../abstract/redis_transaction.dart';
import 'command_rules.dart';
import 'resp_encoder.dart';

/// [RedisTransaction] that collects encoded commands until the transaction
/// is executed by a connection.
class QueuedTransaction with RedisCommands implements RedisTransaction {
  final commands = <QueuedCommand<Object?>>[];
  var _sealed = false;

  /// Whether a queued command changes connection state (like `SELECT`)
  /// that cannot be tracked through a transaction.
  var changesState = false;

  /// Prevents further commands from being queued.
  void seal() => _sealed = true;

  /// Completes the futures of all queued commands with [error].
  void failAll(Object error, [StackTrace? stack]) {
    for (final command in commands) {
      command.fail(error, stack);
    }
  }

  /// Queues [command]. [timeout] is ignored, transactions use the command
  /// timeout of the connection.
  @override
  Future<T> sendCommand<T>(
    List<Object> command,
    T Function(RedisReply reply) decode, {
    Duration? timeout,
  }) {
    if (_sealed) {
      throw StateError(
        'Commands cannot be queued after the transaction callback returned.',
      );
    }

    final name = commandName(command);
    checkTransactionCommand(name, command);
    changesState |= changesConnectionState(name);

    final queued = QueuedCommand<T>(RespEncoder.encode(command), decode);
    commands.add(queued);
    return queued.future;
  }

  /// Uses `EVAL` directly, since a `NOSCRIPT` error of `EVALSHA` is only
  /// known after the transaction was executed.
  @override
  Future<RedisReply> eval(
    RedisScript script, {
    List<String> keys = const [],
    List<Object> args = const [],
  }) => execute(['EVAL', script.source, keys.length, ...keys, ...args]);
}

/// A command queued in a [QueuedTransaction].
class QueuedCommand<T> {
  final Uint8List encoded;
  final T Function(RedisReply reply) _decode;
  final Completer<T> _completer;

  /// The result of the command.
  ///
  /// Marked as ignored, so that failed transactions do not report errors of
  /// result futures nobody is interested in as unhandled. Listeners still
  /// receive the error.
  final Future<T> future;

  factory QueuedCommand(
    Uint8List encoded,
    T Function(RedisReply reply) decode,
  ) {
    final completer = Completer<T>();
    return QueuedCommand._(
      encoded,
      decode,
      completer,
      completer.future..ignore(),
    );
  }

  QueuedCommand._(this.encoded, this._decode, this._completer, this.future);

  void complete(RedisReply reply) {
    if (_completer.isCompleted) {
      return;
    }
    if (reply is RedisErrorReply) {
      _completer.completeError(reply.toException());
      return;
    }
    try {
      _completer.complete(_decode(reply));
    } catch (e, stack) {
      _completer.completeError(e, stack);
    }
  }

  void fail(Object error, [StackTrace? stack]) {
    if (!_completer.isCompleted) {
      _completer.completeError(error, stack);
    }
  }
}
