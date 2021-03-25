import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/persistence.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:postgres/postgres.dart' as postgres;

import 'postgresql_database_adapter.dart';
import 'sql/sql_builder.dart';

const schemaVersionKey = 'schema_version';
const metaTable = '_datahub_meta';

class PostgreSQLDatabaseConnection extends DatabaseConnection {
  final postgres.PostgreSQLConnection _connection;

  PostgreSQLDatabaseConnection(PostgreSQLDatabaseAdapter adapter, this._connection)
      : super(adapter);

  @override
  bool get isOpen => !_connection.isClosed;

  @override
  Future<void> close() async => await _connection.close();

  @override
  Future<void> initializeSchema(DataSchema schema) async {
    _throwClosed();

    if (await schemaExists(schema.name)) {
      final versionString = await getMetaValue(schema.name, schemaVersionKey);
      if (versionString == null) {
        throw PersistenceException(
            'Schema "${schema.name}" does not provide version.');
      }

      final version = int.parse(versionString);
      if (version != schema.version) {
        await schema.migrate(this, version);
      }
    } else {
      await _connection.execute('CREATE SCHEMA ${schema.name}');

      await execute(CreateTableBuilder(schema.name, metaTable)
        ..fields.addAll([
          DataField(FieldType.String, 'key'),
          DataField(FieldType.String, 'value')
        ]));

      // create scheme
      for (final layout in schema.layouts) {
        await execute(
            CreateTableBuilder(schema.name, layout.name, ifNotExists: true)
              ..fields.addAll(layout.fields));
      }
    }
  }

  Future<bool> schemaExists(String schemaName) async {
    final result = await _connection.query(
        'SELECT schema_name FROM information_schema.schemata '
        'WHERE schema_name = @name;',
        substitutionValues: {'name': schemaName});
    return result.isNotEmpty;
  }

  Future<String?> getMetaValue(String schemaName, String key) async {
    final result = await _connection.query(
        'SELECT "value" FROM $schemaName.$metaTable WHERE "key" = @key',
        substitutionValues: {'key': key});

    if (result.isNotEmpty) {
      return result.firstOrNull?.firstOrNull as String?;
    } else {
      return null;
    }
  }

  Future<int> execute(SqlBuilder builder) async {
    final result = builder.buildSql();
    return await _connection.execute(result.a, substitutionValues: result.b);
  }

  //TODO return type?
  Future query(SqlBuilder builder) async {
    final result = builder.buildSql();
    return await _connection.query(result.a, substitutionValues: result.b);
  }

  void _throwClosed() {
    if (!isOpen) {
      throw PersistenceException.closed(this);
    }
  }
}
