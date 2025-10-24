import 'package:boost/boost.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class SqlUpdate with SqlBuilder {
  final SqlQualifiedRelation relation;
  final Sql? where;
  final Map<SqlTypedAttribute, dynamic> values;

  SqlUpdate(this.relation, this.where, this.values);

  @override
  Sql toSql() => Sql.join([
    RawSql('UPDATE '),
    RawSql(relation.toString()),
    RawSql(' SET '),
    for (final (idx, (key, value)) in values.tuples.indexed) ...[
      if (idx > 0) RawSql(', '),
      key.toSql(),
      RawSql(' = '),
      ParameterSql(value, key.type),
    ],
    if (where != null) ...[RawSql(' WHERE '), where!],
  ]);
}
