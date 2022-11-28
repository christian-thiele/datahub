import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:postgres/postgres.dart' as postgres;

import 'sql/sql.dart';

class PostgreSQLDatabaseContext implements DatabaseContext {
  static const _metaKeyColumn = 'key';
  static const _metaValueColumn = 'value';
  final PostgreSQLDatabaseAdapter _adapter;
  final postgres.PostgreSQLExecutionContext _context;

  PostgreSQLDatabaseContext(this._adapter, this._context);

  Future<String?> getMetaValue(String key) async {
    final result = await _context.query(
        'SELECT "value" FROM ${_adapter.schema.name}.$metaTable WHERE "key" = @key',
        substitutionValues: {'key': key});

    if (result.isNotEmpty) {
      return result.firstOrNull?.firstOrNull as String?;
    } else {
      return null;
    }
  }

  Future<void> setMetaValue(String key, String value) async {
    final currentValue = await getMetaValue(key);
    if (currentValue == null) {
      await _context.execute(
          'INSERT INTO ${_adapter.schema.name}.$metaTable ("$_metaKeyColumn", "$_metaValueColumn") VALUES (@key, @value)',
          substitutionValues: {'key': key, 'value': value});
    } else {
      await _context.execute(
          'UPDATE ONLY ${_adapter.schema.name}.$metaTable SET "$_metaValueColumn" = @value WHERE "$_metaKeyColumn" = @key',
          substitutionValues: {'key': key, 'value': value});
    }
  }

  Future<int> execute(SqlBuilder builder) async {
    final result = builder.buildSql();
    return await _context.execute(result.a, substitutionValues: result.b);
  }

  Future<List<List<QueryResult>>> querySql(SqlBuilder builder) async {
    final builderResult = builder.buildSql();
    final result = await _context.query(
      builderResult.a,
      substitutionValues: builderResult.b,
    );

    QueryResult? mapResult(MapEntry<String, Map<String, dynamic>> e) {
      final values =
          e.value.map((key, value) => MapEntry(key, _fromSqlData(value)));
      if (values.values.whereNotNull.isEmpty) {
        return null;
      }

      return QueryResult(
        e.key,
        values,
      );
    }

    List<QueryResult> mapRow(postgres.PostgreSQLResultRow row) {
      final map = <String, Map<String, dynamic>>{};
      for (var i = 0; i < row.columnDescriptions.length; i++) {
        final col = row.columnDescriptions[i];
        final data = map[col.tableName] ??= {};
        data[col.columnName] = row[i];
      }
      return map.entries.map(mapResult).whereNotNull.toList();
    }

    return result.map(mapRow).toList();
  }

  @override
  Future<List<TResult>> query<TResult>(
    QuerySource<TResult> bean, {
    Filter filter = Filter.empty,
    List<QuerySelect> distinct = const <QuerySelect>[],
    Sort sort = Sort.empty,
    int offset = 0,
    int limit = -1,
    bool forUpdate = false,
  }) async {
    final from = SelectFrom.fromQuerySource(_adapter.schema.name, bean);
    final result = await querySql(SelectBuilder(from)
      ..select([const WildcardSelect()])
      ..distinct(distinct)
      ..where(filter)
      ..orderBy(sort)
      ..offset(offset)
      ..limit(limit)
      ..forUpdate(forUpdate));

    return result.map((r) => bean.map(r)).whereNotNull.toList();
  }

  @override
  Future<TDao?> queryId<TDao, TPrimaryKey>(
    PrimaryKeyDataBean<TDao, TPrimaryKey> bean,
    TPrimaryKey id, {
    bool forUpdate = false,
  }) async {
    final primaryKey = bean.primaryKeyField;

    final from = SelectFromTable(_adapter.schema.name, bean.layoutName);
    final result = await querySql(SelectBuilder(from)
      ..where(Filter.equals(primaryKey, id))
      ..forUpdate(forUpdate));

    return result.map((r) => bean.map(r)).firstOrNull;
  }

  @override
  Future<bool> idExists<TPrimaryKey>(
    PrimaryKeyDataBean<dynamic, TPrimaryKey> bean,
    TPrimaryKey id,
  ) async {
    final primaryKey = bean.primaryKeyField;

    final from = SelectFromTable(_adapter.schema.name, bean.layoutName);
    final result = await querySql(SelectBuilder(from)
      ..select([primaryKey])
      ..where(Filter.equals(primaryKey, id)));

    return result.isNotEmpty;
  }

  @override
  Future<dynamic> insert<TDao extends BaseDao>(TDao entry) async {
    final bean = entry.bean;

    final primaryKeyField =
        bean is PrimaryKeyDataBean ? bean.primaryKeyField : null;

    final returning = primaryKeyField != null
        ? SqlBuilder.escapeName(primaryKeyField.name)
        : null;

    final withPrimary = !(primaryKeyField?.autoIncrement ?? false);

    final data = bean.unmap(entry, includePrimaryKey: withPrimary);
    final result = await querySql(
        InsertBuilder(_adapter.schema.name, entry.bean.layoutName)
          ..values(data)
          ..returning(returning));

    return result.firstOrNull?.firstOrNull?.data.values.firstOrNull;
  }

  @override
  Future<void> update<TDao extends PrimaryKeyDao>(TDao object) async {
    final bean = object.bean;
    final data = bean.unmap(object);

    final from = SelectFromTable(_adapter.schema.name, bean.layoutName);
    await execute(UpdateBuilder(from)
      ..values(data)
      ..where(_pkFilter(bean, object.getPrimaryKey())));
  }

  @override
  Future<void> updateId<TPrimaryKey>(
    PrimaryKeyDataBean<dynamic, TPrimaryKey> bean,
    TPrimaryKey id,
    Map<String, dynamic> values,
  ) async {
    final from = SelectFromTable(_adapter.schema.name, bean.layoutName);
    await execute(UpdateBuilder(from)
      ..values(values)
      ..where(_pkFilter(bean, id)));
  }

  @override
  Future<int> updateWhere(
    QuerySource source,
    Map<String, dynamic> values,
    Filter filter,
  ) async {
    final from = SelectFrom.fromQuerySource(_adapter.schema.name, source);
    return await execute(UpdateBuilder(from)
      ..values(values)
      ..where(filter));
  }

  @override
  Future<void> delete<TDao extends PrimaryKeyDao>(TDao object) async {
    final bean = object.bean;
    final from = SelectFromTable(_adapter.schema.name, bean.layoutName);
    await execute(
        DeleteBuilder(from)..where(_pkFilter(bean, object.getPrimaryKey())));
  }

  @override
  Future<void> deleteId<TPrimaryKey>(
    PrimaryKeyDataBean<dynamic, TPrimaryKey> bean,
    dynamic id,
  ) async {
    final from = SelectFromTable(_adapter.schema.name, bean.layoutName);
    await execute(DeleteBuilder(from)..where(_pkFilter(bean, id)));
  }

  @override
  Future<int> deleteWhere(DataBean bean, Filter filter) async {
    final from = SelectFromTable(_adapter.schema.name, bean.layoutName);
    return await execute(DeleteBuilder(from)..where(filter));
  }

  @override
  Future<List<Map<String, dynamic>>> select(
    QuerySource source,
    List<QuerySelect> select, {
    Filter filter = Filter.empty,
    List<QuerySelect> distinct = const <QuerySelect>[],
    Sort sort = Sort.empty,
    int offset = 0,
    int limit = -1,
    bool forUpdate = false,
  }) async {
    final from = SelectFrom.fromQuerySource(_adapter.schema.name, source);
    final results = await querySql(SelectBuilder(from)
      ..where(filter)
      ..orderBy(sort)
      ..offset(offset)
      ..limit(limit)
      ..select(select)
      ..forUpdate(forUpdate));
    return results.map((e) => QueryResult.merge(e)).toList();
  }

  dynamic _fromSqlData(dynamic value) {
    if (value is postgres.PgPoint) {
      return Point(value.latitude, value.longitude);
    }

    return value;
  }

  Filter _pkFilter<TPrimaryKey>(
    PrimaryKeyDataBean<dynamic, TPrimaryKey> layout,
    TPrimaryKey id,
  ) {
    final primaryKey = layout.primaryKeyField;
    return Filter.equals(primaryKey, id);
  }
}
