import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class SqlUpdate implements SqlBuilder {
  final SqlQualifiedRelation relation;
  final Sql? where;
  final Map<SqlTypedAttribute, dynamic> values;

  SqlUpdate(this.relation, this.where, this.values);

  @override
  Sql toSql() => Sql.combine([
        Sql('UPDATE '),
        Sql(relation.toString()),
        Sql(' SET '),
        for (final (idx, (key, value)) in values.tuples.indexed) ...[
          if (idx > 0) Sql(', '),
          key.toSql(),
          Sql(' = '),
          Sql.param(value, key.type),
        ],
        if (where != null) ...[
          Sql(' WHERE '),
          where!,
        ],
      ]);
}
