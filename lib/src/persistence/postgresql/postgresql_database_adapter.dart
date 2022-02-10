import 'package:cl_datahub/cl_datahub.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:postgres/postgres.dart' as postgres;

import 'postgresql_database_migrator.dart';

//TODO factor out postgreSQL related code to separate package

/// [DatabaseAdapter] implementation for PostgreSQL databases.
class PostgreSQLDatabaseAdapter extends DatabaseAdapter {
  static const schemaVersionKey = 'schema_version';

  final String host;
  final int port;
  final String databaseName;
  final String? username;
  final String? password;
  final int timeoutInSeconds;
  final int queryTimeoutInSeconds;
  final String timeZone;
  final bool useSSL;
  final bool isUnixSocket;

  bool _initialized = false;

  /// Parameters represent the constructor parameters of
  /// [postgres.PostgreSQLConnection]
  PostgreSQLDatabaseAdapter(
      DataSchema schema, this.host, this.port, this.databaseName,
      {this.username,
      this.password,
      this.timeoutInSeconds = 30,
      this.queryTimeoutInSeconds = 30,
      this.timeZone = 'UTC',
      this.useSSL = false,
      this.isUnixSocket = false})
      : super(schema);

  @override
  Future<DatabaseConnection> openConnection() async {
    if (!_initialized) {
      throw PersistenceException('Schema not initialized.');
    }

    return await _connection();
  }

  Future<PostgreSQLDatabaseConnection> _connection() async {
    final connection = postgres.PostgreSQLConnection(host, port, databaseName,
        username: username,
        password: password,
        timeoutInSeconds: timeoutInSeconds,
        queryTimeoutInSeconds: queryTimeoutInSeconds,
        timeZone: timeZone,
        useSSL: useSSL,
        isUnixSocket: isUnixSocket);
    await connection.open();

    return PostgreSQLDatabaseConnection(this, connection);
  }

  @override
  Future<void> initializeSchema() async {
    final connection = await _connection();

    if (await _schemaExists(connection)) {
      final versionString = await connection.getMetaValue(schemaVersionKey);
      if (versionString == null) {
        throw PersistenceException(
            'Schema "${schema.name}" does not provide version.');
      }

      final version = int.parse(versionString);
      if (version != schema.version) {
        resolve<LogService>().i(
            'Migrating database schema from v$version to v${schema.version}.',
            sender: 'DataHub');
        final migrator = PostgreSQLDatabaseMigrator(schema, connection);

        await schema.migrate(migrator, version);
        await connection.setMetaValue(
            schemaVersionKey, schema.version.toString());
      }
    } else {
      await connection.execute(RawSql('CREATE SCHEMA ${schema.name}'));

      await connection.execute(CreateTableBuilder(schema.name, metaTable)
        ..fields.addAll([
          PrimaryKey(FieldType.String, 'key'),
          DataField(FieldType.String, 'value')
        ]));

      await connection.setMetaValue(
          schemaVersionKey, schema.version.toString());

      // create scheme
      for (final layout in schema.layouts) {
        await connection.execute(CreateTableBuilder.fromLayout(schema, layout));
      }
    }

    _initialized = true;
  }

  Future<bool> _schemaExists(PostgreSQLDatabaseConnection connection) async {
    final result = await connection.querySql(RawSql(
        'SELECT schema_name FROM information_schema.schemata '
        'WHERE schema_name = @name;',
        {'name': schema.name}));
    return result.isNotEmpty;
  }
}
