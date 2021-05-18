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

  // TODO docs, return type, parameters, this whole thing here basically
  Future<List<Map<String, dynamic>>> query(String tableName, {Filter? filter});

  // TODO insert, update, delete

  // TODO docs, return type, parameters, this whole thing here basically
  Future<dynamic> insert(String tableName, Map<String, dynamic> object);
}
