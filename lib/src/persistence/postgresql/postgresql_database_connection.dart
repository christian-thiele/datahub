import 'package:datahub/datahub.dart';
import 'package:datahub/src/persistence/postgresql/postgresql_database_context.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:postgres/postgres.dart' as postgres;

const metaTable = '_datahub_meta';

class PostgreSQLDatabaseConnection extends DatabaseConnection {
  final postgres.PostgreSQLConnection _connection;

  PostgreSQLDatabaseConnection(
      PostgreSQLDatabaseAdapter adapter, this._connection)
      : super(adapter);

  @override
  bool get isOpen => !_connection.isClosed;

  @override
  Future<void> close() async => await _connection.close();

  // The transaction method from postgres lib behaves the same way this is
  // expected to behave, so no extra handling required.
  @override
  Future<T> runTransaction<T>(
      Future<T> Function(DatabaseContext context) delegate) async {
    return await _connection.transaction((connection) async {
      final context = PostgreSQLDatabaseContext(
          adapter as PostgreSQLDatabaseAdapter, connection);
      return await delegate(context);
    });
  }
}
