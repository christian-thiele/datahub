import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:postgres/postgres.dart' as pg;

import 'abstract/database_context.dart';
import 'postgresql_telemetry.dart';

class PostgresqlContext extends DatabaseContext {
  final pg.Session _session;
  final bool logStatements;
  final String id;
  final PostgresqlTelemetry telemetry;

  const PostgresqlContext(
    this.id,
    this._session,
    this.logStatements, [
    this.telemetry = PostgresqlTelemetry.disabled,
  ]);

  /// Executes [sql] with its values inlined (simple query mode).
  ///
  /// The query text contains the values, so it is only added to the span if
  /// [logStatements] is enabled.
  Future<pg.Result> executeLiteral(Sql sql, {Duration? timeout}) async {
    final query = sql.toLiteralString();
    if (logStatements) {
      log.trace(query);
    }

    return await telemetry.query(
      query,
      includeText: logStatements,
      () => _session.execute(
        pg.Sql(query),
        queryMode: pg.QueryMode.simple,
        timeout: timeout,
      ),
    );
  }

  /// Executes [sql] as parameterized query (extended query mode).
  Future<pg.Result> execute(Sql sql, {Duration? timeout}) async {
    final query = sql.toString();
    if (logStatements) {
      log.trace(query);
      final params = sql.getParameters().toList();
      if (params.isNotEmpty) {
        log.trace(
          'PARAMS: ${params.indexed.map((p) => '${p.$1}: ${p.$2}').join(' ')}',
        );
      }
    }

    return await telemetry.query(
      query,
      includeText: true,
      () => _session.execute(
        pg.Sql(
          query,
          types: sql.getParameterTypes().map((e) => e.pgType).toList(),
        ),
        parameters: sql.getEncodedParameters().toList(),
        queryMode: pg.QueryMode.extended,
        timeout: timeout,
      ),
    );
  }

  Future<void> ensureSchema(String schemaName) async {
    final schemaResult = await execute(
      SqlSelect(SqlQualifiedRelation('information_schema', 'schemata'), [
        SqlColumnAttribute('schema_name'),
      ]),
    );

    final schemaNames = schemaResult.map((e) => e.first.toString()).toList();
    if (!schemaNames.contains(schemaName)) {
      log.warn('Schema "$schemaName" does not exist. Creating schema.');
      await execute(SqlCreateSchema(schemaName));
    }
  }
}
