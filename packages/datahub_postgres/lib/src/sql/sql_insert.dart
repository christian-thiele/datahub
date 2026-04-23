import 'package:boost/boost.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class SqlInsert with SqlBuilder {
  final SqlQualifiedRelation relation;
  final Map<SqlTypedAttribute, dynamic> values;
  final List<SqlAttribute> returning;

  const SqlInsert(this.relation, this.values, {this.returning = const []});

  @override
  Sql toSql() => Sql.join([
    RawSql('INSERT INTO '),
    relation.toSql(),
    RawSql(' ('),
    ...values.keys.map((e) => e.toSqlUnqualified()).separatedBy(RawSql(', ')),
    RawSql(') VALUES ('),
    ...values.entries
        .map<Sql>((e) {
          return switch (e.value) {
            final Sql sql => sql,
            _ => ParameterSql(e.value, e.key.type),
          };
        })
        .separatedBy(RawSql(', ')),
    RawSql(')'),
    if (returning.isNotEmpty) RawSql(' RETURNING '),
    ...returning.cast<Sql>().separatedBy(RawSql(', ')),
  ]);
}
