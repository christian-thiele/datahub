import 'package:cl_datahub/persistence.dart';

/// Abstract interface for connecting to a database.
/// TODO more docs
abstract class DatabaseAdapter<TConnection extends DatabaseConnection> {
  final DataSchema schema;

  DatabaseAdapter(this.schema);

  /// Opens a new connection to the database.
  ///
  /// If initializeSchema has not been called, this is supposed to throw.
  Future<TConnection> openConnection();

  /// Checks and creates or migrates database tables according to the
  /// adapters schema.
  ///
  /// TODO more docs? maybe on migration
  /// TODO migration
  Future<void> initializeSchema();
}

// TODO connection pooling (not within this class but using it)
