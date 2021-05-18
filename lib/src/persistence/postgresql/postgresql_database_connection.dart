import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/persistence.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:postgres/postgres.dart' as postgres;

import 'postgresql_database_adapter.dart';
import 'sql/sql_builder.dart';

const metaTable = '_datahub_meta';

class PostgreSQLDatabaseConnection extends DatabaseConnection {
  final postgres.PostgreSQLConnection _connection;
  static const _metaKeyColumn = 'key';
  static const _metaValueColumn = 'value';

  PostgreSQLDatabaseConnection(PostgreSQLDatabaseAdapter adapter,
      this._connection)
      : super(adapter);

  @override
  bool get isOpen => !_connection.isClosed;

  @override
  Future<void> close() async => await _connection.close();

  Future<String?> getMetaValue(String key) async {
    _throwClosed();
    final result = await _connection.query(
        'SELECT "value" FROM ${adapter.schema
            .name}.$metaTable WHERE "key" = @key',
        substitutionValues: {'key': key});

    if (result.isNotEmpty) {
      return result.firstOrNull?.firstOrNull as String?;
    } else {
      return null;
    }
  }

  Future<String?> setMetaValue(String key, String value) async {
    _throwClosed();
    final currentValue = await getMetaValue(key);
    if (currentValue == null) {
      await _connection.execute(
          'INSERT INTO ${adapter.schema
              .name}.$metaTable ("$_metaKeyColumn", "$_metaValueColumn") VALUES (@key, @value)',
          substitutionValues: {'key': key, 'value': value});
    } else {
      await _connection.execute(
          'UPDATE ONLY ${adapter.schema
              .name}.$metaTable SET "$_metaValueColumn" = @value WHERE "$_metaKeyColumn" = @key',
          substitutionValues: {'key': key, 'value': value});
    }
  }

  Future<int> execute(SqlBuilder builder) async {
    _throwClosed();
    final result = builder.buildSql();
    return await _connection.execute(result.a, substitutionValues: result.b);
  }

  Future<List<Map<String, dynamic>>> querySql(SqlBuilder builder) async {
    _throwClosed();
    final builderResult = builder.buildSql();
    final result = await _connection.query(builderResult.a,
        substitutionValues: builderResult.b);
    return result.map((row) => row.toColumnMap()).toList();
  }


  void _throwClosed() {
    if (!isOpen) {
      throw PersistenceException.closed(this);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> query(String tableName, {Filter? filter}) async {
    return await querySql(
        SelectBuilder(adapter.schema.name, tableName)
          ..where(filter));
  }

  //TODO tableName, Map or maybe rather use dao object? i dunno
  @override
  Future<dynamic> insert(String tableName, Map<String, dynamic> entry) async {
    return await execute(InsertBuilder(adapter.schema.name, tableName)..values(entry));
  }
}
