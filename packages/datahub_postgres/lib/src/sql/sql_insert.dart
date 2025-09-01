import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class SqlInsert implements SqlBuilder {
  final SqlQualifiedRelation relation;
  final Map<SqlTypedAttribute, dynamic> values;
  final SqlAttribute? returning;

  SqlInsert(this.relation, this.values, {this.returning});

  @override
  Sql toSql() => Sql.ofSegments([
        SqlTextSegment('INSERT INTO '),
        SqlTextSegment(relation.toString()),
        SqlTextSegment(' ('),
        SqlTextSegment(values.keys.join(', ')),
        SqlTextSegment(') VALUES ('),
        for (final (idx, (key, value)) in values.tuples.indexed) ...[
          if (idx > 0) SqlTextSegment(', '),
          SqlParamSegment(value, key.type),
        ],
        SqlTextSegment(')'),
        if (returning != null) SqlTextSegment(' RETURNING $returning'),
      ]);
}
