import 'package:cl_datahub/src/persistence/dao/data_layout.dart';
import 'package:cl_datahub/src/persistence/database_adapter.dart';
import 'package:cl_datahub/src/persistence/database_connection.dart';
import 'package:cl_datahub/src/persistence/postgresql/postgresql_database_connection.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:postgres/postgres.dart' as postgres;

//TODO factor out postgresql related code to separate package

/// [DatabaseAdapter] implementation for PostgreSQL databases.
class PostgreSQLDatabaseAdapter extends DatabaseAdapter {
  final String host;
  final int port;
  final String databaseName;
  final String? username;
  final String? password;
  final int timeoutInSeconds;
  final int queryTimeoutInSeconds;
  final String timeZone;
  final bool useSSL;
  final bool isUnixSocket;

  /// Parameters represent the constructor parameters of
  /// [postgres.PostgreSQLConnection]
  PostgreSQLDatabaseAdapter(this.host, this.port, this.databaseName,
      {this.username,
      this.password,
      this.timeoutInSeconds = 30,
      this.queryTimeoutInSeconds = 30,
      this.timeZone = 'UTC',
      this.useSSL = false,
      this.isUnixSocket = false});

  @override
  Future<DatabaseConnection> openConnection() async {
    final connection = postgres.PostgreSQLConnection(host, port, databaseName,
        username: username,
        password: password,
        timeoutInSeconds: timeoutInSeconds,
        queryTimeoutInSeconds: queryTimeoutInSeconds,
        timeZone: timeZone,
        useSSL: useSSL,
        isUnixSocket: isUnixSocket);
    await connection.open();

    return PostgreSQLDatabaseConnection(this, connection);
  }

  @override
  Future initializeSchema(int version, List<DataLayout> layouts) {
    // TODO: implement initializeSchema
    throw UnimplementedError();
  }
}
