import 'dart:async';

import 'package:datahub/datahub.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:postgres/postgres.dart' as postgres;

import 'postgresql_database_context.dart';

class PostgreSQLDatabaseConnection extends DatabaseConnection {
  final postgres.PostgreSQLConnection _connection;

  PostgreSQLDatabaseConnection(
      PostgreSQLDatabaseAdapter adapter, this._connection)
      : super(adapter);

  @override
  bool get isOpen => !_connection.isClosed;

  @override
  Future<void> close() async => await _connection.close();

  // This weird pattern is necessary to preserve the stack trace of exceptions
  // thrown inside of [delegate]. The PostgreSQLConnection.transaction method
  // does not rethrow exceptions but stores them an throws them again, which
  // creates a new stack trace starting from here, which hides the source of
  // the error and can make debugging difficult. By using Completers to keep
  // the execution of delegate outside of the transaction method,
  // we can rethrow exceptions easily.
  @override
  Future<T> runTransaction<T>(
      Future<T> Function(DatabaseContext context) delegate) async {
    final connectionCompleter =
        Completer<postgres.PostgreSQLExecutionContext>();
    final delegateCompleter = Completer();
    final transactionCompleter = Completer();

    unawaited(_connection
        .transaction((connection) async {
          connectionCompleter.complete(connection);
          await delegateCompleter.future;
        })
        .then((_) => transactionCompleter.complete())
        .catchError((e, stack) {
          if (!connectionCompleter.isCompleted) {
            connectionCompleter.completeError(e, stack);
          } else {
            transactionCompleter.completeError(e, stack);
          }
        }));

    final context = PostgreSQLDatabaseContext(
      adapter as PostgreSQLDatabaseAdapter,
      await connectionCompleter.future,
    );

    try {
      return await delegate(context);
    } catch (e) {
      rethrow;
    } finally {
      delegateCompleter.complete();
      await transactionCompleter.future;
    }
  }
}
