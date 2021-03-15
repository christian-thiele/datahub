import 'package:cl_datahub/src/persistence/database_connection.dart';

/// Abstract interface for connecting to a database.
/// TODO more docs
abstract class DatabaseAdapter<TConnection extends DatabaseConnection> {
  /// Opens a new connection to the database.
  Future<TConnection> openConnection();
}

// TODO connection pooling (not within this class but using it)