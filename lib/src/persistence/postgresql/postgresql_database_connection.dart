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

  PostgreSQLDatabaseConnection(
      PostgreSQLDatabaseAdapter adapter, this._connection)
      : super(adapter);

  @override
  bool get isOpen => !_connection.isClosed;

  @override
  Future<void> close() async => await _connection.close();

  Future<String?> getMetaValue(String key) async {
    _throwClosed();
    final result = await _connection.query(
        'SELECT "value" FROM ${adapter.schema.name}.$metaTable WHERE "key" = @key',
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
          'INSERT INTO ${adapter.schema.name}.$metaTable ("key", "value") VALUES (@key, @value)',
          substitutionValues: {'key': key, 'value': value});
    } else {
      await _connection.execute(
          'UPDATE ONLY ${adapter.schema.name}.$metaTable SET "value" = @value WHERE "key" = @key',
          substitutionValues: {'key': key, 'value': value});
    }
  }

  Future<int> execute(SqlBuilder builder) async {
    _throwClosed();
    final result = builder.buildSql();
    return await _connection.execute(result.a, substitutionValues: result.b);
  }

  //TODO return type?
  Future querySql(SqlBuilder builder) async {
    final result = builder.buildSql();
    return await _connection.query(result.a, substitutionValues: result.b);
  }

  void _throwClosed() {
    if (!isOpen) {
      throw PersistenceException.closed(this);
    }
  }

  @override
  Future query(String tableName, {Filter? filter}) async {
    return await querySql(
        SelectBuilder(adapter.schema.name, tableName)..where(filter));
  }
}
