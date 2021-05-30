import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/persistence.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:postgres/postgres.dart' as postgres;

import 'postgresql_database_adapter.dart';
import 'sql/sql.dart';

const metaTable = '_datahub_meta';

class PostgreSQLDatabaseConnection extends DatabaseConnection {
  final postgres.PostgreSQLConnection _connection;
  static const _metaKeyColumn = 'key';
  static const _metaValueColumn = 'value';

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
          'INSERT INTO ${adapter.schema.name}.$metaTable ("$_metaKeyColumn", "$_metaValueColumn") VALUES (@key, @value)',
          substitutionValues: {'key': key, 'value': value});
    } else {
      await _connection.execute(
          'UPDATE ONLY ${adapter.schema.name}.$metaTable SET "$_metaValueColumn" = @value WHERE "$_metaKeyColumn" = @key',
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
  Future<List<TDao>> query<TDao>(DataLayout layout,
      {Filter filter = Filter.empty, int offset = 0, int limit = -1}) async {
    final result =
        await querySql(SelectBuilder(adapter.schema.name, layout.name)
          ..where(filter)
          ..offset(offset)
          ..limit(limit));
    return result.map((e) => layout.map<TDao>(e)).toList();
  }

  @override
  Future<TDao?> queryId<TDao>(DataLayout layout, dynamic id) async {
    final primaryKey = layout.getPrimaryKeyField() ??
        (throw PersistenceException('No primary key found in layout.'));

    final result = await querySql(
        SelectBuilder(adapter.schema.name, layout.name)
          ..where(Filter.equals(primaryKey.name, id)));

    return result.map((e) => layout.map<TDao>(e)).firstOrNull;
  }

  @override
  Future<dynamic> insert<TDao>(DataLayout layout, TDao entry) async {
    final data = layout.unmap(entry);
    final primaryKey = layout.fields.firstOrNullWhere((f) => f is PrimaryKey);
    final returning =
        primaryKey != null ? SqlBuilder.escapeName(primaryKey.name) : null;

    final result =
        await querySql(InsertBuilder(adapter.schema.name, layout.name)
          ..values(data)
          ..returning(returning));

    return result.firstOrNull?.values.firstOrNull;
  }

  @override
  Future<void> update<TDao>(DataLayout layout, TDao object) async {
    final data = layout.unmap(object);

    final primaryKey = layout.getPrimaryKeyField() ??
        (throw PersistenceException('No primary key found in layout.'));

    await execute(UpdateBuilder(adapter.schema.name, layout.name)
      ..values(data)
      ..where(Filter.equals(
          primaryKey.name, layout.unmapField(object, primaryKey))));
  }

  @override
  Future<int> updateWhere(
      DataLayout layout, Map<String, dynamic> values, Filter filter) async {
    return await execute(UpdateBuilder(adapter.schema.name, layout.name)
      ..values(values)
      ..where(filter));
  }

  @override
  Future<void> delete<TDao>(DataLayout layout, TDao object) async {
    final primaryKey = layout.getPrimaryKeyField() ??
        (throw PersistenceException('No primary key found in layout.'));

    await execute(DeleteBuilder(adapter.schema.name, layout.name)
      ..where(Filter.equals(
          primaryKey.name, layout.unmapField(object, primaryKey))));
  }

  @override
  Future<int> deleteWhere(DataLayout layout, Filter filter) async {
    return await execute(
        DeleteBuilder(adapter.schema.name, layout.name)..where(filter));
  }
}
