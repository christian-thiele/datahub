import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:datahub/ioc.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/services.dart';
import 'package:postgres/postgres.dart' as postgres;

import 'postgresql_database_adapter.dart';
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
      Future<T> Function(PostgreSQLDatabaseContext context) delegate) async {
    if (Zone.current[#postgresTransactionConnection] == _connection &&
        Zone.current[#postgresTransactionContext] != null) {
      final context = await (Zone.current[#postgresTransactionContext]
              as Completer<PostgreSQLDatabaseContext>)
          .future;
      return await delegate(context);
    }

    final completer = Completer<_Box<T>>();
    final contextCompleter = Completer<PostgreSQLDatabaseContext>();
    runZonedGuarded(() {
      _connection
          .transaction((c) async {
            final context = PostgreSQLDatabaseContext(
                adapter as PostgreSQLDatabaseAdapter, c);
            contextCompleter.complete(context);
            return await delegate(context);
          })
          .then((r) => completer.complete(_Box<T>.value(r)))
          .catchError(
              (e, stack) => completer.complete(_Box<T>.error(e, stack)));
    }, (error, stack) {
      resolve<LogService?>()?.warn(
        'Unhandled error in postgres package.',
        error: error,
        trace: stack,
      );
    }, zoneValues: {
      #postgresTransactionConnection: _connection,
      #postgresTransactionContext: contextCompleter
    });
    return await (await completer.future).value;
  }
}

class _Box<T> {
  final dynamic error;
  final StackTrace? stack;
  final T? _value;

  _Box.error(this.error, this.stack) : _value = null;

  _Box.value(this._value)
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
