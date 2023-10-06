import 'package:datahub/ioc.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/postgresql.dart';
import 'package:datahub/services.dart';
import 'package:datahub/src/persistence/postgresql/postgresql_database_context.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:postgres/postgres.dart' as postgres;

import 'postgresql_database_migrator.dart';
import 'sql/sql.dart';

//TODO factor out postgreSQL related code to separate package

const metaTable = '_datahub_meta';

//TODO docs for config
/// [DatabaseAdapter] implementation for PostgreSQL databases.
class PostgreSQLDatabaseAdapter
    extends DatabaseAdapter<PostgreSQLDatabaseConnection> {
  static const schemaVersionKey = 'schema_version';

  late final host = config<String>('host');
  late final port = config<int?>('port') ?? 5432;
  late final databaseName = config<String>('database');
  late final username = config<String?>('username');
  late final password = config<String?>('password');
  late final timeoutInSeconds = config<int?>('timeoutInSeconds') ?? 30;
  late final queryTimeoutInSeconds =
      config<int?>('queryTimeoutInSeconds') ?? 30;
  late final timeZone = config<String?>('timeZone') ?? 'UTC';
  late final useSSL = config<bool?>('useSsl') ?? false;
  late final isUnixSocket = config<bool?>('isUnixSocket') ?? false;
  late final ignoreMigration = config<bool?>('ignoreMigration') ?? false;

  PostgreSQLDatabaseAdapter(super.path, super.schema);

  @override
  Future<void> initialize() async {
    await super.initialize();
    await useConnection((connection) async {
      await connection.runTransaction((context) async {
        if (await _schemaExists(context)) {
          String? versionString;
          try {
            versionString = await context.getMetaValue(schemaVersionKey);
          } catch (e) {
            throw PersistenceException(
              'Could not query version for schema "${schema.name}".',
              cause: e,
            );
          }

          if (versionString == null) {
            throw PersistenceException(
                'Schema "${schema.name}" does not provide version.');
          }

          final version = int.parse(versionString);
          if (version != schema.version) {
            if (ignoreMigration) {
              throw PersistenceException(
                  'DataSchema version mismatch: $version != ${schema.version}.');
            }

            resolve<LogService>().i(
                'Migrating database schema from v$version to v${schema.version}.',
                sender: 'DataHub');
            final migrator = PostgreSQLDatabaseMigrator(schema, context);

            await schema.migrate(migrator, version);
            await context.setMetaValue(
                schemaVersionKey, schema.version.toString());
          }
        } else {
          if (ignoreMigration) {
            throw PersistenceException('Schema does not exist.');
          }

          await context.execute(RawSql('CREATE SCHEMA ${schema.name}'));

          await context.execute(CreateTableBuilder(schema.name, metaTable)
            ..fields.addAll([
              PrimaryKey(FieldType.String, metaTable, 'key'),
              DataField(FieldType.String, metaTable, 'value')
            ]));

          await context.setMetaValue(
              schemaVersionKey, schema.version.toString());

          // create scheme
          for (final layout in schema.beans) {
            await context
                .execute(CreateTableBuilder.fromLayout(schema, layout));
          }
        }
      });
    });
  }

  @override
  Future<PostgreSQLDatabaseConnection> openConnection() async {
    final connection = postgres.PostgreSQLConnection(
      host,
      port,
      databaseName,
      username: username,
      password: password,
      timeoutInSeconds: timeoutInSeconds,
      queryTimeoutInSeconds: queryTimeoutInSeconds,
      timeZone: timeZone,
      useSSL: useSSL,
      isUnixSocket: isUnixSocket,
    );
    await connection.open();

    return PostgreSQLDatabaseConnection(this, connection);
  }

  Future<bool> _schemaExists(PostgreSQLDatabaseContext context) async {
    final result = await context.querySql(RawSql(
        'SELECT schema_name FROM information_schema.schemata '
        'WHERE schema_name = @name;',
        {'name': schema.name}));
    return result.isNotEmpty;
  }
}
