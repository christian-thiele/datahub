import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class SqlDelete implements SqlBuilder {
  final SqlQualifiedRelation relation;
  final Sql? where;

  SqlDelete(this.relation, this.where);

  @override
  Sql toSql() => Sql.combine([
        Sql('DELETE FROM '),
        Sql(relation.toString()),
        if (where != null) ...[
          Sql(' WHERE '),
          where!,
        ],
      ]);
}
