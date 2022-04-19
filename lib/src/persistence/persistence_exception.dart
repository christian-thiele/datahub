import 'package:cl_datahub/cl_datahub.dart';

class PersistenceException implements Exception {
  final String message;
  final dynamic cause;

  PersistenceException(this.message, {this.cause});

  PersistenceException.closed(DatabaseConnection connection)
      : this('Connection closed: $connection');

  @override
  String toString() => 'PersistenceException: $message';
}
