import 'package:datahub/datahub.dart';

/// Interface for performing operations / running queries on the database.
///
/// A [DatabaseContext] is usually received by initiating a transaction
/// via a [DatabaseConnection].
abstract class DatabaseContext {
  Future<List<TDao>> query<TDao>(
    DaoDataBean<TDao> bean, {
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
    int limit = -1,
  });

  Future<TDao?> queryId<TDao, TPrimaryKey>(
      PKDaoDataBean<TDao, TPrimaryKey> bean, TPrimaryKey id);

  Future<bool> idExists<TPrimaryKey>(
      PrimaryKeyDataBean<TPrimaryKey> bean, TPrimaryKey id);

  Future<List<dynamic>> select(
    QuerySource bean,
    List<QuerySelect> select, {
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
    int limit = -1,
  });

  /// Returns primary key of inserted object.
  Future<dynamic> insert<TDao extends BaseDao>(TDao object);

  Future<void> update<TDao extends PKBaseDao>(TDao object);

  Future<void> updateId<TPrimaryKey>(PrimaryKeyDataBean<TPrimaryKey> bean,
      TPrimaryKey id, Map<String, dynamic> values);

  /// Returns number of affected rows.
  Future<int> updateWhere(
      BaseDataBean bean, Map<String, dynamic> values, Filter filter);

  Future<void> delete<TDao extends PKBaseDao>(TDao object);

  Future<void> deleteId<TPrimaryKey>(
      PrimaryKeyDataBean<TPrimaryKey> bean, TPrimaryKey id);

  /// Returns number of affected rows.
  Future<int> deleteWhere(DaoDataBean bean, Filter filter);
}
