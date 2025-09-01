import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:datahub_postgres/src/services/abstract/database_context.dart';
import 'package:postgres/postgres.dart' as pg;

class PostgresqlContext extends DatabaseContext {
  final pg.Session _session;

  const PostgresqlContext(this._session);

  Future<pg.Result> execute(SqlBuilder sqlBuilder, {Duration? timeout}) async {
    final sql = sqlBuilder.toSql();
    print('QUERY: $sql');

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
