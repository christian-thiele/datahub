import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:postgres/postgres.dart' as pg;

import 'abstract/database_connection_manager.dart';
import 'postgresql_connection.dart';
import 'postgresql_context.dart';

abstract interface class Postgresql {
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

class PostgresqlService implements Service {
  final Config<bool> logStatements;

  final Config<String> applicationName;
  final Config<String> host;
  final Config<int> port;
  final Config<String> database;
  final Config<String?> username;
  final Config<String?> password;

  final Config<Duration> timeout;
  final Config<Duration> queryTimeout;
  final Config<String> timeZone;
  final Config<bool> useSsl;

  final Config<int> targetPoolSize;
  final Config<Duration> maxConnectionLifetime;
  final Config<Duration> poolTimeout;
  final Config<int> poolQueueLimit;

  /// Whether to reset the session state of a connection (via `DISCARD ALL`)
  /// before returning it to the connection pool.
  ///
  /// This prevents session state (session variables, temporary tables,
  /// advisory locks, ...) from leaking between unrelated consumers of the
  /// pool, at the cost of one extra round-trip per connection use.
  final Config<bool> resetConnectionOnReturn;

  /// Interval for background maintenance of the connection pool.
  ///
  /// On every maintenance run, idle connections that exceeded
  /// [maxConnectionLifetime] are closed and the pool is refilled up to
  /// [targetPoolSize].
  final Config<Duration> poolMaintenanceInterval;

  final Config<bool> enableMetrics;
  final Config<String> metricPrefix;

  const PostgresqlService({
    this.applicationName = const Config('serviceName', defaultValue: 'DataHub'),
    this.host = const Config('host', defaultValue: 'localhost'),
    this.port = const Config('port', defaultValue: 5432),
    this.database = const Config('database', defaultValue: 'postgres'),
    this.username = const Config('username'),
    this.password = const Config('password'),
    this.timeout = const Config('timeout', defaultValue: Duration(seconds: 10)),
    this.queryTimeout = const Config<Duration>(
      'queryTimeout',
      defaultValue: Duration(seconds: 30),
    ),
    this.timeZone = const Config('timeZone', defaultValue: 'UTC'),
    this.useSsl = const Config('useSsl', defaultValue: true),
    this.logStatements = const Config('logStatements', defaultValue: false),
    this.targetPoolSize = const Config('targetPoolSize', defaultValue: 3),
    this.maxConnectionLifetime = const Config(
      'maxConnectionLifetime',
      defaultValue: Duration(hours: 1),
    ),
    this.poolTimeout = const Config<Duration>(
      'poolTimeout',
      defaultValue: Duration(seconds: 5),
    ),
    this.poolQueueLimit = const Config<int>('poolQueueLimit', defaultValue: 10),
    this.resetConnectionOnReturn = const Config<bool>(
      'resetConnectionOnReturn',
      defaultValue: true,
    ),
    this.poolMaintenanceInterval = const Config<Duration>(
      'poolMaintenanceInterval',
      defaultValue: Duration(seconds: 30),
    ),
    this.enableMetrics = const Config<bool>(
      'enableMetrics',
      defaultValue: true,
    ),
    this.metricPrefix = const Config<String>(
      'metricPrefix',
      defaultValue: 'postgresql',
    ),
  });

  @override
  ServiceInstance<PostgresqlService> createInstance() =>
      _PostgresqlServiceInstance();
}

class _PostgresqlServiceInstance extends ServiceInstance<PostgresqlService>
    with DatabaseConnectionManager<PostgresqlService, PostgresqlConnection>
    implements Postgresql {
  static const _listenerMaxBackoff = Duration(seconds: 30);

  final _channels = <String, StreamController<String>>{};
  pg.Connection? _listenerConnection;
  StreamSubscription<pg.Notification>? _listenerSubscription;
  Future<void>? _listenerConnecting;
  var _disposed = false;

  @override
  Future<PostgresqlConnection> openConnection() async {
    return PostgresqlConnection(
      this,
      await _openRawConnection(read(service.applicationName)),
      logStatements: read(service.logStatements),
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
      _ensureListener();
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
  Config<bool> get enableMetrics => service.enableMetrics;

  @override
  Config<Duration> get maxConnectionLifetime => service.maxConnectionLifetime;

  @override
  Config<String> get metricPrefix => service.metricPrefix;

  @override
  Config<int> get targetPoolSize => service.targetPoolSize;
}
