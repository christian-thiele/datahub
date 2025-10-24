import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:postgres/postgres.dart' as pg;

import 'abstract/database_context.dart';

class PostgresqlContext extends DatabaseContext {
  final pg.Session _session;
  final bool logStatements;

  const PostgresqlContext(this._session, this.logStatements);

  Future<pg.Result> executeLiteral(Sql sql, {Duration? timeout}) async {
    return Find<Telemetry>().find().trace(
      'PostgreSQL Query',
      attributes: {'postgresql.query.mode': 'literal'},
      (span) async {
        final query = sql.toLiteralString();
        if (logStatements) {
          span.addAttribute('postgresql.query.sql', query);
          log.trace(query);
        }

        return await _session.execute(
          pg.Sql(query),
          queryMode: pg.QueryMode.simple,
          timeout: timeout,
        );
      },
    );
  }

  Future<pg.Result> execute(Sql sql, {Duration? timeout}) async {
    return Find<Telemetry>().find().trace(
      'PostgreSQL Query',
      attributes: {'postgresql.query.mode': 'extended'},
      (span) async {
        final query = sql.toString();
        if (logStatements) {
          span.addAttribute('postgresql.query.sql', query);
          log.trace(query);
          final params = sql.getParameters().toList();
          if (params.isNotEmpty) {
            log.trace(
              'PARAMS: ${params.indexed.map((p) => '${p.$1}: ${p.$2}').join(' ')}',
            );
          }
        }

        return await _session.execute(
          pg.Sql(
            query,
            types: sql.getParameterTypes().map((e) => e.pgType).toList(),
          ),
          parameters: sql.getEncodedParameters().toList(),
          queryMode: pg.QueryMode.extended,
          timeout: timeout,
        );
      },
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
