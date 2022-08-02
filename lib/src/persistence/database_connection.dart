import 'database_adapter.dart';
import 'database_context.dart';

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

  /// Runs [delegate] inside a transaction.
  ///
  /// If [delegate] returns without throwing an exception, the transaction
  /// is committed and the return value is passed through as return value
  /// of this method.
  ///
  /// If [delegate] throws an exception, the transaction is rolled back
  /// and the exception is rethrown.
  Future<T> runTransaction<T>(
      Future<T> Function(DatabaseContext context) delegate);
}
