import 'database_connection_manager.dart';
import 'database_context.dart';

/// Represents a single connection to a database.
///
/// A [DatabaseConnection] is acquired by using a [DatabaseConnectionService].
/// TODO more docs
abstract class DatabaseConnection {
  final DatabaseConnectionManager adapter;

  DatabaseConnection(this.adapter);

  /// True if this connection is still open and can be used.
  ///
  /// If false, connection is invalid and cannot be used anymore and
  /// a new connection has to be initialized.
  /// (Usually by using [DatabaseConnectionService].)
  bool get isOpen;

  /// Closes the connection.
  ///
  /// The connection is invalid after calling close and cannot
  /// be used anymore.
  Future<void> close();

  /// Resets all session state on the connection (session variables,
  /// temporary tables, advisory locks, prepared statements, ...).
  ///
  /// Called by the [DatabaseConnectionManager] before the connection is
  /// returned to the connection pool, so that no session state leaks
  /// between unrelated consumers of the pool.
  Future<void> reset();

  /// Runs [delegate] inside a transaction.
  ///
  /// If [delegate] returns without throwing an exception, the transaction
  /// is committed and the return value is passed through as return value
  /// of this method.
  ///
  /// If [delegate] throws an exception, the transaction is rolled back
  /// and the exception is rethrown.
  Future<T> runTransaction<T>(
    Future<T> Function(DatabaseContext context) delegate,
  );
}
