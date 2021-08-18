import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/src/persistence/database_adapter.dart';

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

  Future<List<TDao>> query<TDao>(DataLayout layout,
      {Filter filter = Filter.empty, int offset = 0, int limit = -1});

  Future<TDao?> queryId<TDao>(DataLayout layout, dynamic id);

  Future<bool> idExists<TDao>(DataLayout layout, dynamic id);

  Future<List<dynamic>> select(DataLayout layout, List<QuerySelect> select,
      {Filter filter = Filter.empty, int offset = 0, int limit = -1});

  /// Returns primary key of inserted object.
  Future<dynamic> insert<TDao>(DataLayout layout, TDao object);

  Future<void> update<TDao>(DataLayout layout, TDao object);

  Future<void> updateId<TDao>(
      DataLayout layout, dynamic id, Map<String, dynamic> values);

  /// Returns number of affected rows.
  Future<int> updateWhere(
      DataLayout layout, Map<String, dynamic> values, Filter filter);

  Future<void> delete<TDao>(DataLayout layout, TDao object);

  /// Returns number of affected rows.
  Future<int> deleteWhere(DataLayout layout, Filter filter);
}
