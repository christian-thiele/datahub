import 'database_connection.dart';

class PersistenceException implements Exception {
  final String message;
  final dynamic cause;

  PersistenceException(this.message, {this.cause});

  PersistenceException.closed(DatabaseConnection connection)
      : this('Connection closed: $connection');

  PersistenceException.internal(String message)
      : this('A DataHub internal error occurred! This error should not have '
            'happened and it is very likely, that this error is not your '
            'fault.\nPlease report this error, this message and instructions '
            'to reproduce it to the DataHub Issue Tracker.\n'
            'Details: $message');

  @override
  String toString() => 'PersistenceException: $message';
}
