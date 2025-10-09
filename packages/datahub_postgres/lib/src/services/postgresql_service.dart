import 'package:datahub/datahub.dart';
import 'package:postgres/postgres.dart' as pg;

import 'abstract/database_connection_manager.dart';
import 'postgresql_connection.dart';
import 'postgresql_context.dart';

import 'dart:async';

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

  final Config<int> timeout;
  final Config<int> queryTimeout;
  final Config<String> timeZone;
  final Config<bool> useSsl;

  PostgresqlService({
    this.applicationName = const Config('serviceName', defaultValue: 'DataHub'),
    this.host = const Config('host', defaultValue: 'localhost'),
    this.port = const Config('port', defaultValue: 5432),
    this.database = const Config('database', defaultValue: 'postgres'),
    this.username = const Config('username'),
    this.password = const Config('password'),
    this.timeout = const Config<int>('timeout', defaultValue: 30),
    this.queryTimeout = const Config<int>('queryTimeout', defaultValue: 30),
    this.timeZone = const Config<String>('timeZone', defaultValue: 'UTC'),
    this.useSsl = const Config<bool>('useSsl', defaultValue: true),
    this.logStatements = const Config('logStatements', defaultValue: false),
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
          connectTimeout: Duration(seconds: read(service.timeout)),
          queryTimeout: Duration(seconds: read(service.queryTimeout)),
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
}
