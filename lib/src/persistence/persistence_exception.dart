import 'package:cl_datahub/cl_datahub.dart';

class PersistenceException implements Exception {
  final String message;

  PersistenceException(this.message);

  PersistenceException.closed(DatabaseConnection connection)
      : this('Connection closed: $connection');

  @override
  String toString() => 'PersistenceException: $message';
}
