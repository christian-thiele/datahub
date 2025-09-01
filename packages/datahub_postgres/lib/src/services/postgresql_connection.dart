import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:postgres/postgres.dart';

import 'abstract/database_connection.dart';
import 'postgresql_context.dart';

class PostgresqlConnection extends DatabaseConnection {
  final Connection _connection;

  PostgresqlConnection(super.adapter, this._connection);

  @override
  Future<void> close() async {
    await _connection.close();
  }

  @override
  bool get isOpen => _connection.isOpen;

  @override
  Future<T> runTransaction<T>(
      Future<T> Function(PostgresqlContext context) delegate) async {
    if (Zone.current[#postgresTransactionConnection] == _connection &&
        Zone.current[#postgresTransactionContext] != null) {
      final context = await (Zone.current[#postgresTransactionContext]
              as Completer<PostgresqlContext>)
          .future;
      return await delegate(context);
    }

    final completer = Completer<_Box<T>>();
    final contextCompleter = Completer<PostgresqlContext>();
    runZonedGuarded(() {
      _connection
          .runTx((session) async {
            final context = PostgresqlContext(session);
            contextCompleter.complete(context);
            return await delegate(context);
          })
          .then((r) => completer.complete(_Box<T>.value(r)))
          .catchError(
              (e, stack) => completer.complete(_Box<T>.error(e, stack)));
    }, (error, stack) {
      if (!completer.isCompleted) {
        completer.complete(_Box<T>.error(error, stack));
      } else {
        resolve<LogService?>()?.warn(
          'Unhandled error in postgres transaction.',
          error: error,
          trace: stack,
        );
      }
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
