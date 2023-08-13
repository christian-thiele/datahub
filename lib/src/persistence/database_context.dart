import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';

/// Interface for performing operations / running queries on the database.
///
/// A [DatabaseContext] is usually received by initiating a transaction
/// via a [DatabaseConnection].
abstract class DatabaseContext {
  Future<List<TDao>> query<TDao>(
    QuerySource<TDao> bean, {
    Filter filter = Filter.empty,
    List<QuerySelect> distinct = const <QuerySelect>[],
    Sort sort = Sort.empty,
    int offset = 0,
    int limit = -1,
    bool forUpdate = false,
  });

  Future<TDao?> queryId<TDao, TPrimaryKey>(
      PrimaryKeyDataBean<TDao, TPrimaryKey> bean, TPrimaryKey id);

  Future<bool> idExists<TPrimaryKey>(
      PrimaryKeyDataBean<dynamic, TPrimaryKey> bean, TPrimaryKey id);

  Future<List<Map<String, dynamic>>> select(
    QuerySource bean,
    List<QuerySelect> select, {
    List<QuerySelect> distinct = const <QuerySelect>[],
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
    int limit = -1,
    bool forUpdate = false,
  });

  /// Returns primary key of inserted object.
  Future<dynamic> insert<TDao extends BaseDao>(TDao object);

  Future<void> update<TDao extends PrimaryKeyDao>(TDao object);

  Future<void> updateId<TPrimaryKey>(
    PrimaryKeyDataBean<dynamic, TPrimaryKey> bean,
    TPrimaryKey id,
    Map<String, dynamic> values,
  );

  /// Returns number of affected rows.
  Future<int> updateWhere(
    QuerySource source,
    Map<String, dynamic> values,
    Filter filter,
  );

  Future<void> delete<TDao extends PrimaryKeyDao>(TDao object);

  Future<void> deleteId<TPrimaryKey>(
    PrimaryKeyDataBean<dynamic, TPrimaryKey> bean,
    TPrimaryKey id,
  );

  /// Returns number of affected rows.
  Future<int> deleteWhere(DataBean bean, Filter filter);
}

/// Utility methods that can be used on any [DatabaseContext].
extension DatabaseContextUtils on DatabaseContext {
  /// Checks if there are any entries that match the filter.
  Future<bool> any(QuerySource bean, {Filter filter = Filter.empty}) async {
    return await count(bean, filter: filter) > 0;
  }

  /// Returns the number of elements that match the [filter].
  Future<int> count(QuerySource bean, {Filter filter = Filter.empty}) async {
    final result = await select(bean, [QuerySelect.count], filter: filter);
    return result.firstOrNull?[QuerySelect.count.alias] ?? 0;
  }

  /// Returns the first entry of the query.
  Future<TDao?> first<TDao>(
    QuerySource<TDao> source, {
    Filter filter = Filter.empty,
    List<QuerySelect> distinct = const <QuerySelect>[],
    Sort sort = Sort.empty,
    int offset = 0,
    bool forUpdate = false,
  }) async {
    final result = await query<TDao>(
      source,
      filter: filter,
      distinct: distinct,
      sort: sort,
      offset: offset,
      limit: 1,
      forUpdate: forUpdate,
    );

    return result.firstOrNull;
  }
}
