import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:postgres/postgres.dart' as postgres;

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

  Future<void> setMetaValue(String key, String value) async {
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
    return result
        .map((row) => row
            .toColumnMap()
            .map((key, value) => MapEntry(key, _fromSqlData(value))))
        .toList();
  }

  void _throwClosed() {
    if (!isOpen) {
      throw PersistenceException.closed(this);
    }
  }

  @override
  Future<List<TDao>> query<TDao>(
    DaoDataBean<TDao> bean, {
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
    int limit = -1,
  }) async {
    final result =
        await querySql(SelectBuilder(adapter.schema.name, bean.layoutName)
          ..select([const WildcardSelect()]) //TODO maybe "only" dto fields?
          ..where(filter)
          ..orderBy(sort)
          ..offset(offset)
          ..limit(limit));
    return result.map(bean.map).toList();
  }

  @override
  Future<TDao?> queryId<TDao, TPrimaryKey>(
      PKDaoDataBean<TDao, TPrimaryKey> bean, TPrimaryKey id) async {
    final primaryKey = bean.primaryKeyField;

    final result = await querySql(
        SelectBuilder(adapter.schema.name, bean.layoutName)
          ..where(Filter.equals(primaryKey, id)));

    return result.map(bean.map).firstOrNull;
  }

  @override
  Future<bool> idExists<TPrimaryKey>(
      PrimaryKeyDataBean<TPrimaryKey> bean, TPrimaryKey id) async {
    final primaryKey = bean.primaryKeyField;

    final result =
        await querySql(SelectBuilder(adapter.schema.name, bean.layoutName)
          ..select([FieldSelect(primaryKey)])
          ..where(Filter.equals(primaryKey, id)));

    return result.isNotEmpty;
  }

  @override
  Future<dynamic> insert<TDao extends BaseDao>(TDao entry) async {
    final bean = entry.bean;
    final data = bean.unmap(entry);
    final returning = bean is PrimaryKeyDataBean
        ? SqlBuilder.escapeName(
            (bean as PrimaryKeyDataBean).primaryKeyField.name)
        : null;

    final result =
        await querySql(InsertBuilder(adapter.schema.name, entry.bean.layoutName)
          ..values(data)
          ..returning(returning));

    return result.firstOrNull?.values.firstOrNull;
  }

  @override
  Future<void> update<TDao extends PKBaseDao>(TDao object) async {
    final bean = object.bean;
    final data = bean.unmap(object);

    await execute(UpdateBuilder(adapter.schema.name, bean.layoutName)
      ..values(data)
      ..where(_pkFilter(bean, object.getPrimaryKey())));
  }

  @override
  Future<void> updateId<TPrimaryKey>(PrimaryKeyDataBean<TPrimaryKey> bean,
      TPrimaryKey id, Map<String, dynamic> values) async {
    await execute(UpdateBuilder(adapter.schema.name, bean.layoutName)
      ..values(values)
      ..where(_pkFilter(bean, id)));
  }

  @override
  Future<int> updateWhere(
      BaseDataBean bean, Map<String, dynamic> values, Filter filter) async {
    return await execute(UpdateBuilder(adapter.schema.name, bean.layoutName)
      ..values(values)
      ..where(filter));
  }

  @override
  Future<void> delete<TDao extends PKBaseDao>(TDao object) async {
    final bean = object.bean;
    await execute(DeleteBuilder(adapter.schema.name, bean.layoutName)
      ..where(_pkFilter(bean, object.getPrimaryKey())));
  }

  @override
  Future<void> deleteId<TPrimaryKey>(
      PrimaryKeyDataBean<TPrimaryKey> bean, dynamic id) async {
    await execute(DeleteBuilder(adapter.schema.name, bean.layoutName)
      ..where(_pkFilter(bean, id)));
  }

  @override
  Future<int> deleteWhere(BaseDataBean bean, Filter filter) async {
    return await execute(
        DeleteBuilder(adapter.schema.name, bean.layoutName)..where(filter));
  }

  @override
  Future<List> select(
    BaseDataBean bean,
    List<QuerySelect> select, {
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
    int limit = -1,
  }) {
    return querySql(SelectBuilder(adapter.schema.name, bean.layoutName)
      ..where(filter)
      ..orderBy(sort)
      ..offset(offset)
      ..limit(limit)
      ..select(select));
  }

  dynamic _fromSqlData(dynamic value) {
    if (value is postgres.PgPoint) {
      return Point(value.latitude, value.longitude);
    }

    return value;
  }

  Filter _pkFilter<TPrimaryKey>(
      PrimaryKeyDataBean<TPrimaryKey> layout, TPrimaryKey id) {
    final primaryKey = layout.primaryKeyField;
    return Filter.equals(primaryKey, id);
  }
}
