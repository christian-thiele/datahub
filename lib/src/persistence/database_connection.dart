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
  Future close();
}