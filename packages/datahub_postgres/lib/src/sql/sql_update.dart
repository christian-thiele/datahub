import 'package:boost/boost.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class SqlUpdate with SqlBuilder {
  final SqlQualifiedRelation relation;
  final Sql? where;
  final Map<SqlTypedAttribute, dynamic> values;
  final Sql? from;
  final List<SqlAttribute> returning;

  SqlUpdate(
    this.relation,
    this.where,
    this.values, {
    this.from,
    this.returning = const [],
  });

  @override
  Sql toSql() => Sql.join([
    RawSql('UPDATE '),
    relation.toSql(),
    RawSql(' SET '),
    for (final (idx, (key, value)) in values.tuples.indexed) ...[
      if (idx > 0) RawSql(', '),
      key.toSqlUnqualified(),
      RawSql(' = '),
      switch (value) {
        Sql() => value,
        _ => ParameterSql(value, key.type),
      },
    ],
    if (from case final from?) RawSql(' FROM ') + from,
    if (where case final where?) RawSql(' WHERE ') + where,
    if (returning.isNotEmpty) RawSql(' RETURNING '),
    ...returning.cast<Sql>().separatedBy(RawSql(', ')),
  ]);
}
