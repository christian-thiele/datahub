import 'dart:async';
import 'dart:convert';

import 'package:datahub/telemetry.dart';

import '../abstract/redis_message.dart';
import '../abstract/redis_reply.dart';
import '../protocol/redis_socket_connection.dart';

/// Manages Pub/Sub subscriptions on a dedicated connection.
///
/// The connection is opened when the first channel is subscribed, health
/// checked with `PING` and re-established with exponential backoff when
/// lost, re-subscribing all channels and patterns.
class RedisSubscriber {
  static const _initialBackoff = Duration(milliseconds: 250);
  static const _maxBackoff = Duration(seconds: 30);

  final Future<RedisSocketConnection> Function() _connect;
  final Duration healthCheckInterval;

  /// Zone the connection loop and timers run in, so that they are not
  /// bound to the zone of whoever subscribed first.
  final Zone _zone;

  final _channels = <String, _Subscription>{};
  final _patterns = <String, _Subscription>{};

  RedisSocketConnection? _connection;
  Future<void>? _connecting;
  Timer? _healthTimer;

  /// Wakes the connection loop from its backoff when disposed.
  Completer<void>? _backoff;
  var _awaitingReply = false;
  var _disposed = false;

  RedisSubscriber(
    this._connect, {
    required this.healthCheckInterval,
    required Zone zone,
  }) : _zone = zone;

  Stream<RedisMessage> subscribe(String channel) => _stream(channel, false);

  Stream<RedisMessage> psubscribe(String pattern) => _stream(pattern, true);

  Stream<RedisMessage> _stream(String name, bool isPattern) {
    _checkNotDisposed();

    SubscriptionHandle? handle;
    late final StreamController<RedisMessage> controller;
    controller = StreamController<RedisMessage>.broadcast(
      onListen: () {
        if (_disposed) {
          unawaited(controller.close());
          return;
        }
        handle = listen(
          name,
          isPattern: isPattern,
          onMessage: controller.add,
          onDone: () => unawaited(controller.close()),
        );
      },
      onCancel: () {
        handle?.cancel();
        handle = null;
      },
    );
    return controller.stream;
  }

  /// Registers [onMessage] for the channel (or pattern) [name].
  ///
  /// The channel is subscribed on the server while at least one listener is
  /// registered. [onDone] is called when the subscriber is disposed.
  SubscriptionHandle listen(
    String name, {
    required bool isPattern,
    required void Function(RedisMessage message) onMessage,
    void Function()? onDone,
  }) {
    _checkNotDisposed();

    final subscriptions = isPattern ? _patterns : _channels;
    var subscription = subscriptions[name];
    if (subscription == null) {
      subscription = subscriptions[name] = _Subscription();
      if (_connection case final connection? when connection.isOpen) {
        connection.write([isPattern ? 'PSUBSCRIBE' : 'SUBSCRIBE', name]);
      } else {
        _ensureConnected();
      }
    }

    final listener = _Listener(onMessage, onDone);
    subscription.listeners.add(listener);

    final current = subscription;
    return SubscriptionHandle._(
      current.ready.future,
      () => _unlisten(subscriptions, name, current, listener, isPattern),
    );
  }

  void _unlisten(
    Map<String, _Subscription> subscriptions,
    String name,
    _Subscription subscription,
    _Listener listener,
    bool isPattern,
  ) {
    if (!subscription.listeners.remove(listener) ||
        subscription.listeners.isNotEmpty ||
        !identical(subscriptions[name], subscription)) {
      return;
    }

    subscriptions.remove(name);
    if (_connection case final connection? when connection.isOpen) {
      connection.write([isPattern ? 'PUNSUBSCRIBE' : 'UNSUBSCRIBE', name]);
    }
  }

  bool get _hasSubscriptions => _channels.isNotEmpty || _patterns.isNotEmpty;

  void _ensureConnected() {
    if (_disposed ||
        _connecting != null ||
        (_connection?.isOpen ?? false) ||
        !_hasSubscriptions) {
      return;
    }

    _connecting = _zone.run(_connectLoop).whenComplete(() {
      _connecting = null;
    });
  }

  Future<void> _connectLoop() async {
    var backoff = _initialBackoff;
    while (!_disposed && _hasSubscriptions) {
      try {
        final connection = await _connect();
        if (_disposed) {
          await connection.close();
          return;
        }
        _attach(connection);
        return;
      } catch (e, stack) {
        log.warn(
          'Could not open Redis subscriber connection, '
          'retrying in ${backoff.inMilliseconds}ms.',
          error: e,
          stack: stack,
        );
        await _sleep(backoff);
        backoff = backoff * 2 > _maxBackoff ? _maxBackoff : backoff * 2;
      }
    }
  }

  /// Waits for [duration], or until [dispose] is called.
  Future<void> _sleep(Duration duration) {
    final completer = _backoff = Completer<void>();
    final timer = Timer(duration, completer.complete);
    return completer.future.whenComplete(() {
      timer.cancel();
      _backoff = null;
    });
  }

  void _attach(RedisSocketConnection connection) {
    _connection = connection;
    _awaitingReply = false;
    connection.enterSubscriberMode(_onReply);

    if (_channels.isNotEmpty) {
      connection.write(['SUBSCRIBE', ..._channels.keys]);
    }
    if (_patterns.isNotEmpty) {
      connection.write(['PSUBSCRIBE', ..._patterns.keys]);
    }

    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(
      healthCheckInterval,
      (_) => _checkHealth(connection),
    );
    unawaited(connection.closed.then((_) => _onClosed(connection)));
  }

  /// Sends a PING every interval and closes the connection if nothing at all
  /// was received during a whole interval, which detects connections that
  /// died silently (e.g. dropped by a NAT gateway or load balancer).
  void _checkHealth(RedisSocketConnection connection) {
    if (!identical(connection, _connection)) {
      return;
    }
    if (_awaitingReply) {
      log.warn('Redis subscriber connection did not respond to PING.');
      unawaited(connection.close());
      return;
    }
    _awaitingReply = true;
    connection.write(['PING']);
  }

  void _onClosed(RedisSocketConnection connection) {
    if (!identical(connection, _connection)) {
      return;
    }

    _connection = null;
    _healthTimer?.cancel();
    _healthTimer = null;
    for (final subscription in [..._channels.values, ..._patterns.values]) {
      if (subscription.ready.isCompleted) {
        subscription.ready = Completer();
      }
    }

    if (!_disposed) {
      log.warn('Redis subscriber connection lost, reconnecting.');
      _ensureConnected();
    }
  }

  void _onReply(RedisReply reply) {
    _awaitingReply = false;
    try {
      switch (reply) {
        case RedisArray(items: [RedisBulkString(:final bytes), ...final args]):
          switch ((ascii.decode(bytes, allowInvalid: true), args)) {
            case ('message', [final channel, final data]):
              final name = channel.asString!;
              _channels[name]?.dispatch(RedisMessage(name, data.asBytes!));
            case ('pmessage', [final pattern, final channel, final data]):
              final patternName = pattern.asString!;
              _patterns[patternName]?.dispatch(
                RedisMessage(
                  channel.asString!,
                  data.asBytes!,
                  pattern: patternName,
                ),
              );
            case ('subscribe', [final channel, _]):
              _channels[channel.asString!]?.markReady();
            case ('psubscribe', [final pattern, _]):
              _patterns[pattern.asString!]?.markReady();
            default:
            // unsubscribe confirmations and PING replies
          }
        case RedisErrorReply(:final message):
          log.warn('Redis subscriber connection received error: $message');
        default:
        // PONG while no channel is subscribed
      }
    } catch (e, stack) {
      log.error(
        'Could not process Redis Pub/Sub message.',
        error: e,
        stack: stack,
      );
    }
  }

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('RedisService is disposed.');
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _healthTimer?.cancel();
    if (_backoff case final backoff? when !backoff.isCompleted) {
      backoff.complete();
    }
    final connection = _connection;
    _connection = null;
    await connection?.close();

    final subscriptions = [..._channels.values, ..._patterns.values];
    _channels.clear();
    _patterns.clear();
    for (final subscription in subscriptions) {
      for (final listener in subscription.listeners.toList()) {
        listener.onDone?.call();
      }
    }
  }
}

/// Registration of a listener, see [RedisSubscriber.listen].
class SubscriptionHandle {
  /// Completes when the server confirmed the subscription.
  final Future<void> ready;
  final void Function() _cancel;

  SubscriptionHandle._(this.ready, this._cancel);

  void cancel() => _cancel();
}

class _Subscription {
  final listeners = <_Listener>{};
  var ready = Completer<void>();

  void markReady() {
    if (!ready.isCompleted) {
      ready.complete();
    }
  }

  void dispatch(RedisMessage message) {
    for (final listener in listeners.toList()) {
      listener.onMessage(message);
    }
  }
}

class _Listener {
  final void Function(RedisMessage message) onMessage;
  final void Function()? onDone;

  _Listener(this.onMessage, this.onDone);
}
