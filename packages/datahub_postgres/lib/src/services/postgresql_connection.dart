import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:postgres/postgres.dart';

import 'abstract/database_connection.dart';
import 'postgresql_context.dart';

class PostgresqlConnection extends DatabaseConnection {
  final Connection _connection;
  final bool logStatements;
  late final String _connectionId;

  PostgresqlConnection(
    super.adapter,
    this._connection, {
    this.logStatements = false,
  }) {
    _connectionId = uuid();
  }

  @override
  Future<void> close() async {
    await _connection.close();
  }

  @override
  bool get isOpen => _connection.isOpen;

  @override
  Future<T> runTransaction<T>(
    Future<T> Function(PostgresqlContext context) delegate,
  ) async {
    if (Zone.current[#postgresTransactionConnection] == _connection &&
        Zone.current[#postgresTransactionContext] != null) {
      final context =
          await (Zone.current[#postgresTransactionContext]
                  as Completer<PostgresqlContext>)
              .future;
      return await delegate(context);
    }

    final contextCompleter = Completer<PostgresqlContext>();
    return await runZoned(
      () {
        final telemetry = Find<Telemetry>().find();
        return _connection.runTx((session) async {
          return await telemetry.trace(
            'PostgreSQL Transaction',
            type: SpanType.internal,
            attributes: {'postgresql.connection.id': _connectionId},
            (span) async {
              final context = PostgresqlContext(session, logStatements);
              contextCompleter.complete(context);
              return await delegate(context);
            },
          );
        });
      },
      zoneValues: {
        #postgresTransactionConnection: _connection,
        #postgresTransactionContext: contextCompleter,
      },
    );
  }
}
