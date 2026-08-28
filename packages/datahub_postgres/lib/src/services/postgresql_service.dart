import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:postgres/postgres.dart' as pg;

import 'abstract/database_connection_manager.dart';
import 'postgresql_connection.dart';
import 'postgresql_context.dart';

abstract interface class Postgresql {
  Future<T> runTransaction<T>(
    Future<T> Function(PostgresqlContext context) delegate,
  );

  Future<TResult> useConnection<TResult>(
    Future<TResult> Function(PostgresqlConnection) delegate, {
    Duration? timeout,
  });
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
  @override
  Future<PostgresqlConnection> openConnection() async {
    return PostgresqlConnection(
      this,
      await pg.Connection.open(
        pg.Endpoint(
          host: read(service.host),
          port: read(service.port),
          database: read(service.database),
          username: read(service.username),
          password: read(service.password),
        ),
        settings: pg.ConnectionSettings(
          applicationName: read(service.applicationName),
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
      ),
      logStatements: read(service.logStatements),
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
