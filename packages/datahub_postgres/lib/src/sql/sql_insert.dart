import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class SqlInsert implements SqlBuilder {
  final SqlQualifiedRelation relation;
  final Map<SqlTypedAttribute, dynamic> values;
  final SqlAttribute? returning;

  SqlInsert(this.relation, this.values, {this.returning});

  @override
  Sql toSql() => Sql.combine([
        Sql('INSERT INTO '),
        Sql(relation.toString()),
        Sql(' ('),
        values.keys.map((e) => e.toSql()).joinSql(', '),
        Sql(') VALUES ('),
        for (final (idx, (key, value)) in values.tuples.indexed) ...[
          if (idx > 0) Sql(', '),
          Sql.param(value, key.type),
        ],
        Sql(')'),
        if (returning != null) ...[
          Sql(' RETURNING '),
          returning!.toSql(),
        ],
      ]);
}
