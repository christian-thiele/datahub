import 'package:cl_datahub/src/persistence/database_connection.dart';
import 'package:cl_datahub/src/persistence/postgresql/postgresql_database_adapter.dart';
import 'package:postgres/postgres.dart' as postgres;

class PostgreSQLDatabaseConnection extends DatabaseConnection {
  final postgres.PostgreSQLConnection _connection;

  PostgreSQLDatabaseConnection(
      PostgreSQLDatabaseAdapter adapter, this._connection)
      : super(adapter);

  @override
  bool get isOpen => !_connection.isClosed;

  @override
  Future close() async => await _connection.close();

}
