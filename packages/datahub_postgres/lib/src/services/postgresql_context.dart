import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:postgres/postgres.dart' as pg;

import 'abstract/database_context.dart';

class PostgresqlContext extends DatabaseContext {
  final PostgresqlService _service;
  final pg.Session _session;

  const PostgresqlContext(this._service, this._session);

  Future<pg.Result> execute(SqlBuilder sqlBuilder, {Duration? timeout}) async {
    final sql = sqlBuilder.toSql();
    if (_service.logStatements) {
      resolve<LogService?>()?.debug('QUERY: $sql', sender: 'datahub_postgres');
    }

    return await _session.execute(
      pg.Sql(
        sql.toString(),
        types: sql.getParameterTypes().map((e) => e.pgType).toList(),
      ),
      parameters: sql.getParameters(),
      queryMode: pg.QueryMode.extended,
      timeout: timeout,
    );
  }
}
