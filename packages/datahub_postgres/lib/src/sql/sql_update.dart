import 'package:boost/boost.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class SqlUpdate(
  final SqlQualifiedRelation relation,
  final Sql? where,
  final Map<SqlTypedAttribute, dynamic> values, {
  final Sql? from,
  final List<SqlAttribute> returning = const [],
}) with SqlBuilder {
  @override
  Sql toSql() => Sql.join([
    const RawSql('UPDATE '),
    relation.toSql(),
    const RawSql(' SET '),
    for (final (idx, (key, value)) in values.tuples.indexed) ...[
      if (idx > 0) const RawSql(', '),
      key.toSqlUnqualified(),
      const RawSql(' = '),
      switch (value) {
        Sql() => value,
        _ => ParameterSql(value, key.type),
      },
    ],
    if (from case final from?) const RawSql(' FROM ') + from,
    if (where case final where?) const RawSql(' WHERE ') + where,
    if (returning.isNotEmpty) const RawSql(' RETURNING '),
    ...returning.cast<Sql>().separatedBy(const RawSql(', ')),
  ]);
}
