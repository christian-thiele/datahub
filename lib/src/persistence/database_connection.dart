import 'package:cl_datahub/cl_datahub.dart';

/// Represents a single connection to a database.
///
/// A [DatabaseConnection] is acquired by using a [DatabaseAdapter].
/// TODO more docs
abstract class DatabaseConnection {
  final DatabaseAdapter adapter;

  DatabaseConnection(this.adapter);

  /// True if this connection is still open and can be used.
  ///
  /// If false, connection is invalid and cannot be used anymore and
  /// a new connection has to be initialized.
  /// (Usually by using [DatabaseAdapter].)
  bool get isOpen;

  /// Closes the connection.
  ///
  /// The connection is invalid after calling close and cannot
  /// be used anymore.
  Future<void> close();

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
