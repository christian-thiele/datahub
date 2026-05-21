import 'package:datahub_postgres/datahub_postgres.dart';

class SqlDelete with SqlBuilder {
  final SqlQualifiedRelation relation;
  final Sql? where;

  SqlDelete(this.relation, this.where);

  @override
  Sql toSql() => Sql.join([
    RawSql('DELETE FROM '),
    relation.toSql(),
    if (where != null) ...[RawSql(' WHERE '), where!],
  ]);
}
