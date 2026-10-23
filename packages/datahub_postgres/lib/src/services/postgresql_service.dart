import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:postgres/postgres.dart' as pg;

import 'abstract/database_connection_manager.dart';
import 'postgresql_connection.dart';
import 'postgresql_context.dart';
import 'postgresql_telemetry.dart';

abstract interface class Postgresql() {
  Future<T> runTransaction<T>(
    Future<T> Function(PostgresqlContext context) delegate,
  );

  /// Runs [delegate] in a new transaction on its own pooled connection.
  ///
  /// Unlike [runTransaction], this never joins a transaction of the calling
  /// zone. Must not be awaited while holding locks that [delegate] waits for.
  Future<T> runDetachedTransaction<T>(
    Future<T> Function(PostgresqlContext context) delegate,
  );

  Future<TResult> useConnection<TResult>(
    Future<TResult> Function(PostgresqlConnection) delegate, {
    Duration? timeout,
  });

  /// Returns a broadcast stream of payloads sent to [channel] via `NOTIFY` or
  /// `pg_notify`.
  ///
  /// Notifications are received on a dedicated connection outside of the
  /// connection pool, which is re-established automatically when lost.
  Stream<String> listen(String channel);
}

class const PostgresqlService({
  final Config<String> applicationName = const Config(
    'serviceName',
    defaultValue: 'DataHub',
  ),
  final Config<String> host = const Config('host', defaultValue: 'localhost'),
  final Config<int> port = const Config('port', defaultValue: 5432),
  final Config<String> database = const Config(
    'database',
    defaultValue: 'postgres',
  ),
  final Config<String?> username = const Config('username'),
  final Config<String?> password = const Config('password'),
  final Config<Duration> timeout = const Config(
    'timeout',
    defaultValue: Duration(seconds: 10),
  ),
  final Config<Duration> queryTimeout = const Config<Duration>(
    'queryTimeout',
    defaultValue: Duration(seconds: 30),
  ),
  final Config<String> timeZone = const Config('timeZone', defaultValue: 'UTC'),
  final Config<bool> useSsl = const Config('useSsl', defaultValue: true),
  final Config<bool> logStatements = const Config(
    'logStatements',
    defaultValue: false,
  ),
  final Config<int> targetPoolSize = const Config(
    'targetPoolSize',
    defaultValue: 3,
  ),
  final Config<Duration> maxConnectionLifetime = const Config(
    'maxConnectionLifetime',
    defaultValue: Duration(hours: 1),
  ),
  final Config<Duration> poolTimeout = const Config<Duration>(
    'poolTimeout',
    defaultValue: Duration(seconds: 5),
  ),
  final Config<int> poolQueueLimit = const Config<int>(
    'poolQueueLimit',
    defaultValue: 10,
  ),

  /// Whether to reset the session state of a connection (via `DISCARD ALL`)
  /// before returning it to the connection pool.
  ///
  /// This prevents session state (session variables, temporary tables,
  /// advisory locks, ...) from leaking between unrelated consumers of the
  /// pool, at the cost of one extra round-trip per connection use.
  final Config<bool> resetConnectionOnReturn = const Config<bool>(
    'resetConnectionOnReturn',
    defaultValue: true,
  ),

  /// Interval for background maintenance of the connection pool.
  ///
  /// On every maintenance run, idle connections that exceeded
  /// [maxConnectionLifetime] are closed and the pool is refilled up to
  /// [targetPoolSize].
  final Config<Duration> poolMaintenanceInterval = const Config<Duration>(
    'poolMaintenanceInterval',
    defaultValue: Duration(seconds: 30),
  ),
  final Config<bool> enableMetrics = const Config<bool>(
    'enableMetrics',
    defaultValue: true,
  ),
  final Config<String> metricPrefix = const Config<String>(
    'metricPrefix',
    defaultValue: 'postgresql',
  ),

  /// Trace queries and transactions as spans, see [PostgresqlTelemetry].
  final Config<bool> enableTracing = const Config<bool>(
    'enableTracing',
    defaultValue: true,
  ),
}) implements Service {
  @override
  ServiceInstance<PostgresqlService> createInstance() =>
      _PostgresqlServiceInstance();
}

class _PostgresqlServiceInstance()
    extends ServiceInstance<PostgresqlService>
    with DatabaseConnectionManager<PostgresqlService, PostgresqlConnection>
    implements Postgresql {
  static const _listenerMaxBackoff = Duration(seconds: 30);

  final _channels = <String, StreamController<String>>{};
  pg.Connection? _listenerConnection;
  StreamSubscription<pg.Notification>? _listenerSubscription;
  Future<void>? _listenerConnecting;
  var _disposed = false;

  // created on first use, which is when the pool is filled while
  // initializing
  late final PostgresqlTelemetry _telemetry = _createTelemetry();

  PostgresqlTelemetry _createTelemetry() {
    final enableMetrics = read(service.enableMetrics);
    final enableTracing = read(service.enableTracing);
    if (!enableMetrics && !enableTracing) {
      return PostgresqlTelemetry.disabled;
    }

    return PostgresqlTelemetry(
      telemetry: find(const Find<Telemetry>()),
      metricPrefix: read(service.metricPrefix),
      enableMetrics: enableMetrics,
      enableTracing: enableTracing,
      host: read(service.host),
      port: read(service.port),
      database: read(service.database),
    );
  }

  @override
  void onPoolChanged({
    required int target,
    required int total,
    required int available,
  }) => _telemetry.poolSize(target: target, total: total, available: available);

  @override
  Future<PostgresqlConnection> onPoolTake(
    Future<PostgresqlConnection> Function() take,
  ) => _telemetry.poolWait(take);

  @override
  Future<PostgresqlConnection> openConnection() async {
    return PostgresqlConnection(
      this,
      await _openRawConnection(read(service.applicationName)),
      logStatements: read(service.logStatements),
      telemetry: _telemetry,
    );
  }

  Future<pg.Connection> _openRawConnection(String applicationName) async {
    return await pg.Connection.open(
      pg.Endpoint(
        host: read(service.host),
        port: read(service.port),
        database: read(service.database),
        username: read(service.username),
        password: read(service.password),
      ),
      settings: pg.ConnectionSettings(
        applicationName: applicationName,
        connectTimeout: read(service.timeout),
        queryTimeout: read(service.queryTimeout),
        timeZone: read(service.timeZone),
        sslMode: switch (read(service.useSsl)) {
          true => pg.SslMode.require,
          false => pg.SslMode.disable,
        },
        queryMode: pg.QueryMode.extended,
        typeRegistry: pg.TypeRegistry(
          encoders: [
            // this "hack" allows PostgresqlDataTypes to return EncodedValues
            (value, _) => value.value is pg.EncodedValue
                ? value.value as pg.EncodedValue
                : null,
          ],
        ),
      ),
    );
  }

  @override
  Future<T> runTransaction<T>(
    Future<T> Function(PostgresqlContext context) delegate,
  ) async {
    return await useConnection((connection) async {
      return await connection.runTransaction(delegate);
    });
  }

  @override
  Future<T> runDetachedTransaction<T>(
    Future<T> Function(PostgresqlContext context) delegate,
  ) async {
    return await runDetached(
      () => runZoned(
        () => runTransaction(delegate),
        zoneValues: {
          #postgresTransactionConnection: null,
          #postgresTransactionContext: null,
        },
      ),
    );
  }

  @override
  Stream<String> listen(String channel) {
    if (_disposed) {
      throw StateError('PostgresqlService is disposed.');
    }

    final controller = _channels[channel] ??= StreamController.broadcast();
    if (_listenerConnection case final connection? when connection.isOpen) {
      unawaited(_subscribeChannel(connection, channel));
    } else {
      inInstanceZone(_ensureListener);
    }

    return controller.stream;
  }

  void _ensureListener() {
    if (_disposed ||
        _listenerConnecting != null ||
        (_listenerConnection?.isOpen ?? false)) {
      return;
    }

    _listenerConnecting = _connectListener().whenComplete(() {
      _listenerConnecting = null;
      if (!_disposed && !(_listenerConnection?.isOpen ?? false)) {
        // lost while subscribing to channels
        Timer(const Duration(milliseconds: 250), _ensureListener);
      }
    });
  }

  Future<void> _connectListener() async {
    var backoff = const Duration(milliseconds: 250);
    while (!_disposed) {
      try {
        final connection = await _openRawConnection(
          '${read(service.applicationName)}/listener',
        );
        if (_disposed) {
          await connection.close();
          return;
        }

        _listenerConnection = connection;
        _listenerSubscription = connection.channels.all.listen((notification) {
          _channels[notification.channel]?.add(notification.payload);
        });
        unawaited(connection.closed.then((_) => _onListenerClosed(connection)));

        for (final channel in _channels.keys.toList()) {
          await _subscribeChannel(connection, channel);
        }
        return;
      } catch (e, stack) {
        log.warn(
          'Could not open PostgreSQL notification listener connection.',
          error: e,
          stack: stack,
        );
        await Future<void>.delayed(backoff);
        backoff = backoff * 2 > _listenerMaxBackoff
            ? _listenerMaxBackoff
            : backoff * 2;
      }
    }
  }

  Future<void> _subscribeChannel(
    pg.Connection connection,
    String channel,
  ) async {
    try {
      await connection.execute(
        'LISTEN ${Sql.escapeName(channel)}',
        queryMode: pg.QueryMode.simple,
      );
      _channels[channel]?.add('');
    } catch (e, stack) {
      // a lost connection is re-established by _onListenerClosed
      log.warn(
        'Could not listen to channel "$channel".',
        error: e,
        stack: stack,
      );
    }
  }

  Future<void> _onListenerClosed(pg.Connection connection) async {
    if (!identical(_listenerConnection, connection)) {
      return;
    }

    _listenerConnection = null;
    await _listenerSubscription?.cancel();
    _listenerSubscription = null;

    if (!_disposed) {
      log.warn('PostgreSQL notification listener connection lost.');
      _ensureListener();
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    final connection = _listenerConnection;
    _listenerConnection = null;
    await _listenerSubscription?.cancel();
    await connection?.close();
    for (final controller in _channels.values) {
      await controller.close();
    }
    _channels.clear();
    await super.dispose();
  }

  @override
  Config<Duration> get poolTimeout => service.poolTimeout;

  @override
  Config<int> get poolQueueLimit => service.poolQueueLimit;

  @override
  Config<bool> get resetConnectionOnReturn => service.resetConnectionOnReturn;

  @override
  Config<Duration> get poolMaintenanceInterval =>
      service.poolMaintenanceInterval;

  @override
  Config<Duration> get maxConnectionLifetime => service.maxConnectionLifetime;

  @override
  Config<int> get targetPoolSize => service.targetPoolSize;
}
