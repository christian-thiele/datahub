import 'package:boost/boost.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/postgresql.dart';
import 'package:datahub/services.dart';
import 'package:datahub/src/persistence/postgresql/postgresql_database_context.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:postgres/postgres.dart' as postgres;

import 'postgresql_data_types.dart';
import 'postgresql_database_migrator.dart';
import 'sql/param_sql.dart';
import 'sql/sql.dart';
import 'type_registry.dart';

//TODO factor out postgreSQL related code to separate package

const metaTable = '_datahub_meta';

/// [DatabaseAdapter] implementation for PostgreSQL databases.

//TODO docs for config
class PostgreSQLDatabaseAdapter
    extends DatabaseAdapter<PostgreSQLDatabaseConnection>
    implements TypeRegistry {
  static const schemaVersionKey = 'schema_version';

  static const defaultDataTypes = <PostgresqlDataType>{
    PostgresqlStringDataType(),
    PostgresqlIntDataType(),
    PostgresqlSerialDataType(),
    PostgresqlBoolDataType(),
    PostgresqlDoubleDataType(),
    PostgresqlDateTimeDataType(),
  };

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

  final _typeRegistry = <PostgresqlDataType>{};

  PostgreSQLDatabaseAdapter(super.path, super.schema,
      {List<PostgresqlDataType> types = const []}) {
    _typeRegistry.addAll(types);
    _typeRegistry.addAll(defaultDataTypes);
  }

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
            final migrator = PostgreSQLDatabaseMigrator(this, schema, context);

            await schema.migrate(migrator, version);
            await context.setMetaValue(
                schemaVersionKey, schema.version.toString());
          }
        } else {
          if (ignoreMigration) {
            throw PersistenceException('Schema does not exist.');
          }

          await context.execute(ParamSql('CREATE SCHEMA ')
            ..addParam(schema.name, postgres.PostgreSQLDataType.text));

          final createMetaTable =
              CreateTableBuilder(this, schema.name, metaTable)
                ..fields.addAll([
                  PrimaryKey(
                      type: StringDataType(),
                      layoutName: metaTable,
                      name: 'key'),
                  DataField(
                      type: StringDataType(),
                      layoutName: metaTable,
                      name: 'value')
                ]);
          await context.execute(createMetaTable.buildSql());

          await context.setMetaValue(
              schemaVersionKey, schema.version.toString());

          // create schema
          for (final layout in schema.beans) {
            await context.execute(
                CreateTableBuilder.fromLayout(this, schema, layout).buildSql());
          }
        }
      });
    });
  }

  @override
  PostgresqlDataType findType<T, TDataType extends DataType<T>>(
      DataType<T> dataType) {
    return _typeRegistry
            .firstOrNullWhere((e) => e is PostgresqlDataType<T, TDataType>) ??
        (throw PersistenceException(
            'No type factory registered for ${dataType.runtimeType} in adapter.'));
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
    final result = await context.querySql(
      ParamSql('SELECT schema_name FROM information_schema.schemata '
          'WHERE schema_name = ')
        ..addParam(schema.name, postgres.PostgreSQLDataType.text),
    );
    return result.isNotEmpty;
  }
}
