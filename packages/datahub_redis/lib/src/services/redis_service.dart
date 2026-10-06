import 'dart:async';
import 'dart:math';

import 'package:datahub/datahub.dart';

import '../abstract/redis.dart';
import '../abstract/redis_commands.dart';
import '../abstract/redis_connection.dart';
import '../abstract/redis_message.dart';
import '../abstract/redis_reply.dart';
import '../abstract/redis_transaction.dart';
import '../protocol/redis_socket_connection.dart';
import '../protocol/scan.dart';
import '../redis_telemetry.dart';
import 'redis_lock_handle.dart';
import 'redis_subscriber.dart';

/// Provides [Redis] and a distributed [LockProvider] for string keys.
///
/// Commands are sent over a pool of connections. Pub/Sub uses a dedicated
/// connection that is opened on the first subscription.
///
/// ## Locks
///
/// Locks are Redis keys (prefixed with [lockPrefix]) that hold a random token
/// of the holder and expire after [lockLeaseDuration]. The lease is renewed
/// in the background while the lock is held, so a lock only expires when its
/// holder crashed or lost the connection to Redis for a whole lease.
/// Waiting acquirers are woken through Pub/Sub when a lock is released and
/// poll every [lockRetryInterval] otherwise. Waiters are not served in FIFO
/// order.
///
/// Locks are exclusive across all instances using the same Redis server (and
/// database-independent [lockPrefix]). They are not safe against failover to
/// a replica that did not receive the lock key yet.
class RedisService implements Service {
  /// Client name reported to the server (`CLIENT SETNAME`). Whitespace is
  /// replaced by `-`.
  final Config<String> clientName;

  final Config<String> host;
  final Config<int> port;

  /// User for authentication (Redis 6 ACL). Only used if [password] is set,
  /// the default user is used if null.
  final Config<String?> username;

  /// Password for authentication. Authentication is skipped if null.
  final Config<String?> password;

  /// Database index selected on every connection.
  final Config<int> database;

  final Config<bool> useTls;

  /// Timeout for establishing a connection, including TLS handshake and
  /// authentication.
  final Config<Duration> timeout;

  /// Default timeout for a single command.
  ///
  /// A connection is closed when a command on it times out, since the late
  /// reply could otherwise be taken for the reply of another command.
  /// Blocking commands like `BLPOP` need a longer timeout passed to
  /// [RedisCommands.execute].
  final Config<Duration> commandTimeout;

  final Config<int> targetPoolSize;
  final Config<Duration> maxConnectionLifetime;

  /// Maximum time to wait for a connection from the pool.
  final Config<Duration> poolTimeout;

  /// Maximum number of requests waiting for a connection from the pool,
  /// further requests fail with [PoolQueueLimitException].
  ///
  /// Every command takes a connection for one round trip, so bursts of
  /// concurrent commands (e.g. `Future.wait` over many keys) queue up here.
  /// For bulk operations, pipeline the commands on a single connection with
  /// [Redis.useConnection] instead.
  final Config<int> poolQueueLimit;

  /// Interval for background maintenance of the connection pool.
  ///
  /// On every maintenance run, idle connections that exceeded
  /// [maxConnectionLifetime] are closed and the pool is refilled up to
  /// [targetPoolSize].
  final Config<Duration> poolMaintenanceInterval;

  /// Pooled connections that were idle for longer than this are checked with
  /// `PING` before they are used, and the Pub/Sub connection is pinged in
  /// this interval.
  ///
  /// This detects connections that died silently, for example when dropped
  /// by a NAT gateway or a load balancer, before a command is sent on them.
  final Config<Duration> healthCheckInterval;

  /// Prefix of the Redis keys (and Pub/Sub channels) used for locks.
  final Config<String> lockPrefix;

  /// Time after which a lock expires unless it is renewed by its holder.
  final Config<Duration> lockLeaseDuration;

  /// Interval in which a waiting acquirer retries to acquire a lock, in case
  /// no release notification is received.
  final Config<Duration> lockRetryInterval;

  /// Publish metrics about commands, the connection pool, locks and Pub/Sub.
  final Config<bool> enableMetrics;
  final Config<String> metricPrefix;

  /// Trace every command, transaction, connection setup, pool checkout and
  /// lock acquisition as span.
  ///
  /// Busy services create many spans, which can displace other spans if
  /// the exporter buffer is full. Disable tracing for those.
  final Config<bool> enableTracing;

  const RedisService({
    this.clientName = const Config('serviceName', defaultValue: 'DataHub'),
    this.host = const Config('host', defaultValue: 'localhost'),
    this.port = const Config('port', defaultValue: 6379),
    this.username = const Config('username'),
    this.password = const Config('password'),
    this.database = const Config('database', defaultValue: 0),
    this.useTls = const Config('useTls', defaultValue: false),
    this.timeout = const Config('timeout', defaultValue: Duration(seconds: 10)),
    this.commandTimeout = const Config<Duration>(
      'commandTimeout',
      defaultValue: Duration(seconds: 10),
    ),
    this.targetPoolSize = const Config('targetPoolSize', defaultValue: 4),
    this.maxConnectionLifetime = const Config(
      'maxConnectionLifetime',
      defaultValue: Duration(hours: 1),
    ),
    this.poolTimeout = const Config<Duration>(
      'poolTimeout',
      defaultValue: Duration(seconds: 5),
    ),
    this.poolQueueLimit = const Config<int>(
      'poolQueueLimit',
      defaultValue: 1000,
    ),
    this.poolMaintenanceInterval = const Config<Duration>(
      'poolMaintenanceInterval',
      defaultValue: Duration(seconds: 30),
    ),
    this.healthCheckInterval = const Config<Duration>(
      'healthCheckInterval',
      defaultValue: Duration(seconds: 30),
    ),
    this.lockPrefix = const Config<String>(
      'lockPrefix',
      defaultValue: 'datahub:lock:',
    ),
    this.lockLeaseDuration = const Config<Duration>(
      'lockLeaseDuration',
      defaultValue: Duration(seconds: 30),
    ),
    this.lockRetryInterval = const Config<Duration>(
      'lockRetryInterval',
      defaultValue: Duration(milliseconds: 500),
    ),
    this.enableMetrics = const Config<bool>(
      'enableMetrics',
      defaultValue: true,
    ),
    this.metricPrefix = const Config<String>(
      'metricPrefix',
      defaultValue: 'redis',
    ),
    this.enableTracing = const Config<bool>(
      'enableTracing',
      defaultValue: true,
    ),
  });

  @override
  ServiceInstance<RedisService> createInstance() => _RedisServiceInstance();
}

class _RedisServiceInstance extends ServiceInstance<RedisService>
    with RedisCommands
    implements Redis, LockProvider<String> {
  /// Zone value key for the connection bound by [useConnection].
  final _bindingKey = Object();

  /// Monotonic clock for lock leases.
  final _clock = Stopwatch()..start();
  final _random = Random.secure();

  /// The zone [initialize] ran in. Background work (Pub/Sub connection,
  /// lock renewal) runs here, so it is neither bound to a caller's
  /// connection nor attributed to a caller's context.
  late final Zone _zone;

  late final Duration _poolTimeout;
  late final Duration _healthCheckInterval;
  late final Duration _timeout;

  late final _pool = Pool<RedisSocketConnection>(
    read(service.targetPoolSize),
    _openConnection,
    maxLifetime: read(service.maxConnectionLifetime),
    checkIsLive: _checkIsLive,
    maxQueueLength: read(service.poolQueueLimit),
    onReturn: (connection) => connection.reset(),
    maintenanceInterval: read(service.poolMaintenanceInterval),
    autoRefill: true,
    onChange: _updateMetrics,
    onRemoveItem: (connection) => connection.close(),
  );

  RedisSubscriber? _subscriber;
  late final _unbound = _UnboundCommands(this);
  final _locks = <RedisLockHandle>{};
  final _lockWaiters = <void Function()>{};
  var _disposed = false;

  var _telemetry = RedisTelemetry.disabled;

  Map<String, String> get _targetLabels => {
    'redis.host': read(service.host),
    'redis.port': read(service.port).toString(),
  };

  @override
  Future<void> initialize() async {
    await super.initialize();
    _zone = Zone.current;
    _poolTimeout = read(service.poolTimeout);
    _healthCheckInterval = read(service.healthCheckInterval);
    _timeout = read(service.timeout);

    final enableMetrics = read(service.enableMetrics);
    final enableTracing = read(service.enableTracing);
    if (enableMetrics || enableTracing) {
      _telemetry = RedisTelemetry(
        telemetry: find(Find<Telemetry>()),
        metricPrefix: read(service.metricPrefix),
        enableMetrics: enableMetrics,
        enableTracing: enableTracing,
        host: read(service.host),
        port: read(service.port),
      );
    }

    await _pool.fill();
    log.info(
      'Redis service started.',
      labels: {
        ..._targetLabels,
        'redis.database': read(service.database).toString(),
        'redis.pool_size': _pool.total.toString(),
      },
    );
  }

  Future<RedisSocketConnection> _openConnection() {
    log.debug('Opening Redis connection.', labels: _targetLabels);
    return RedisSocketConnection.connect(
      telemetry: _telemetry,
      host: read(service.host),
      port: read(service.port),
      useTls: read(service.useTls),
      connectTimeout: _timeout,
      commandTimeout: read(service.commandTimeout),
      username: read(service.username),
      password: read(service.password),
      database: read(service.database),
      clientName: read(service.clientName).replaceAll(RegExp(r'\s'), '-'),
    );
  }

  FutureOr<bool> _checkIsLive(RedisSocketConnection connection) {
    if (!connection.isOpen) {
      return false;
    }
    if (connection.idleTime < _healthCheckInterval) {
      return true;
    }
    return connection
        .sendInternalCommand(['PING'], (_) => true, timeout: _timeout)
        .catchError((_) {
          _telemetry.healthCheckFailed();
          return false;
        });
  }

  void _updateMetrics() => _telemetry.poolSize(
    target: _pool.targetSize,
    total: _pool.total,
    available: _pool.available,
  );

  /// The connection bound to the current zone by [useConnection], if its
  /// delegate is still running.
  RedisSocketConnection? get _boundConnection =>
      switch (Zone.current[_bindingKey]) {
        _ConnectionBinding(active: true, :final connection) => connection,
        _ => null,
      };

  /// Runs [delegate] with a connection from the pool.
  ///
  /// Keeps working while [dispose] runs until the pool is disposed, so that
  /// held locks can still be released.
  Future<T> _withPooledConnection<T>(
    Future<T> Function(RedisSocketConnection connection) delegate, {
    Duration? timeout,
  }) async {
    if (_pool.isDisposed) {
      throw StateError('RedisService is disposed.');
    }

    final RedisSocketConnection connection;
    try {
      connection = await _telemetry.poolWait(
        () => _pool.take(timeout: timeout ?? _poolTimeout),
      );
    } on PoolQueueLimitException {
      _telemetry.poolRejected();
      rethrow;
    }
    try {
      return await delegate(connection);
    } finally {
      _pool.give(connection);
    }
  }

  @override
  Future<T> useConnection<T>(
    Future<T> Function(RedisConnection connection) delegate, {
    Duration? timeout,
  }) async {
    if (_boundConnection case final connection?) {
      return await delegate(connection);
    }

    return await _telemetry.traced(
      'Redis Use Connection',
      () => _withPooledConnection((connection) async {
        final binding = _ConnectionBinding(connection);
        try {
          return await runZoned(
            () => delegate(connection),
            zoneValues: {_bindingKey: binding},
          );
        } finally {
          // callbacks that outlive the delegate must not use the connection
          // after it was returned to the pool
          binding.active = false;
        }
      }, timeout: timeout),
    );
  }

  @override
  Future<T> sendCommand<T>(
    List<Object> command,
    T Function(RedisReply reply) decode, {
    Duration? timeout,
  }) {
    if (_boundConnection case final connection?) {
      return connection.sendCommand(command, decode, timeout: timeout);
    }
    return _withPooledConnection(
      (connection) => connection.sendCommand(command, decode, timeout: timeout),
    );
  }

  @override
  Future<bool> transaction(void Function(RedisTransaction tx) commands) {
    if (_boundConnection case final connection?) {
      return connection.transaction(commands);
    }
    return _withPooledConnection(
      (connection) => connection.transaction(commands),
    );
  }

  @override
  Stream<String> scan({String? match, int? count, String? type}) =>
      scanKeys(this, match: match, count: count, type: type);

  RedisSubscriber get _pubSub {
    if (_disposed) {
      throw StateError('RedisService is disposed.');
    }
    return _subscriber ??= RedisSubscriber(
      _openConnection,
      healthCheckInterval: _healthCheckInterval,
      zone: _zone,
      telemetry: _telemetry,
      targetLabels: _targetLabels,
    );
  }

  @override
  Stream<RedisMessage> subscribe(String channel) => _pubSub.subscribe(channel);

  @override
  Stream<RedisMessage> psubscribe(String pattern) =>
      _pubSub.psubscribe(pattern);

  @override
  Future<LockHandle> acquireLock(
    String key, {
    Duration? timeout = Duration.zero,
  }) async {
    if (_disposed) {
      throw StateError('RedisService is disposed.');
    }

    // contention is an expected outcome and not reported as span error
    final handle = await _telemetry.traced<RedisLockHandle?>(
      'Redis Lock Acquire',
      () async {
        try {
          return await _acquireLock(key, timeout);
        } on ResourceLockedException {
          return null;
        }
      },
      attributes: {
        'db.system.name': 'redis',
        'redis.lock.timeout_ms': ?timeout?.inMilliseconds,
      },
    );
    return handle ?? (throw ResourceLockedException());
  }

  Future<RedisLockHandle> _acquireLock(String key, Duration? timeout) async {
    final lockKey = '${read(service.lockPrefix)}$key';
    final token = _newToken();
    final waited = Stopwatch()..start();

    if (await _tryLock(key, lockKey, token) case final handle?) {
      _telemetry.lockAcquired(waited.elapsed);
      return handle;
    }
    _telemetry.lockContended();
    if (timeout != null && timeout <= Duration.zero) {
      throw ResourceLockedException();
    }

    final deadline = timeout == null ? null : _clock.elapsed + timeout;
    final retryInterval = read(service.lockRetryInterval);

    var signal = Completer<void>();
    void wake() {
      if (!signal.isCompleted) {
        signal.complete();
      }
    }

    _lockWaiters.add(wake);
    final subscription = _pubSub.listen(
      lockKey,
      isPattern: false,
      onMessage: (_) => wake(),
    );
    // the lock may have been released before the subscription was active
    unawaited(subscription.ready.then((_) => wake()));

    try {
      while (true) {
        final remaining = deadline == null ? null : deadline - _clock.elapsed;
        if (remaining != null && remaining <= Duration.zero) {
          throw ResourceLockedException();
        }

        final wait = remaining == null || remaining > retryInterval
            ? retryInterval
            : remaining;
        await _sleep(signal.future, wait);
        if (_disposed) {
          throw StateError('RedisService is disposed.');
        }

        // wakes from here on are kept for the next iteration
        signal = Completer<void>();
        if (await _tryLock(key, lockKey, token) case final handle?) {
          _telemetry.lockAcquired(waited.elapsed);
          return handle;
        }
      }
    } finally {
      _lockWaiters.remove(wake);
      subscription.cancel();
    }
  }

  Future<RedisLockHandle?> _tryLock(
    String key,
    String lockKey,
    String token,
  ) async {
    final leaseDuration = read(service.lockLeaseDuration);
    final sentAt = _clock.elapsed;
    final acquired = await _unbound.set(
      lockKey,
      token,
      ttl: leaseDuration,
      ifAbsent: true,
    );
    if (!acquired) {
      return null;
    }

    final handle = RedisLockHandle(
      key: lockKey,
      name: key,
      token: token,
      leaseDuration: leaseDuration,
      validUntil: sentAt + leaseDuration,
      commands: _unbound,
      clock: _clock,
      zone: _zone,
      telemetry: _telemetry,
      onFinished: (handle) {
        _locks.remove(handle);
        _telemetry.locksHeld(_locks.length);
      },
    );
    _locks.add(handle);
    _telemetry.locksHeld(_locks.length);

    if (_disposed) {
      await handle.abandon();
      throw StateError('RedisService is disposed.');
    }
    return handle;
  }

  String _newToken() => [
    for (var i = 0; i < 16; i++)
      _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();

  /// Completes when [signal] completes or after [duration], whichever comes
  /// first.
  Future<void> _sleep(Future<void> signal, Duration duration) {
    final completer = Completer<void>();
    final timer = Timer(duration, () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    unawaited(
      signal.then((_) {
        timer.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }),
    );
    return completer.future;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    for (final wake in _lockWaiters.toList()) {
      wake();
    }
    await Future.wait([for (final lock in _locks.toList()) lock.abandon()]);
    await _subscriber?.dispose();
    await _pool.dispose();
    log.debug('Redis service stopped.', labels: _targetLabels);
    await super.dispose();
  }
}

class _ConnectionBinding {
  final RedisSocketConnection connection;
  var active = true;

  _ConnectionBinding(this.connection);
}

/// Pooled commands that ignore connections bound by
/// [_RedisServiceInstance.useConnection], used for lock management.
class _UnboundCommands with RedisCommands {
  final _RedisServiceInstance _service;

  _UnboundCommands(this._service);

  @override
  Future<T> sendCommand<T>(
    List<Object> command,
    T Function(RedisReply reply) decode, {
    Duration? timeout,
  }) => _service._withPooledConnection(
    (connection) => connection.sendCommand(command, decode, timeout: timeout),
  );
}
