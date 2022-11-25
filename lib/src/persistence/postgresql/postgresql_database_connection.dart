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

  @override
  Future<T> runTransaction<T>(
      Future<T> Function(DatabaseContext context) delegate) async {
    final completer = Completer<Box<T>>();
    runZonedGuarded(
      () {
        _connection
            .transaction((c) async {
              final context = PostgreSQLDatabaseContext(
                  adapter as PostgreSQLDatabaseAdapter, c);
              return await delegate(context);
            })
            .then((r) => completer.complete(Box<T>.value(r)))
            .catchError(
                (e, stack) => completer.complete(Box<T>.error(e, stack)));
      },
      (error, stack) {
        resolve<LogService?>()?.warn(
          'Unhandled error in postgres package.',
          error: error,
          trace: stack,
        );
      },
    );
    return await (await completer.future).value;
  }
}

class Box<T> {
  final dynamic error;
  final StackTrace? stack;
  final T? _value;

  Box.error(this.error, this.stack) : _value = null;

  Box.value(this._value)
      : error = null,
        stack = null;

  Future<T> get value {
    if (error != null) {
      return Future<T>.error(error, stack);
    } else {
      return Future<T>.value(_value);
    }
  }
}
