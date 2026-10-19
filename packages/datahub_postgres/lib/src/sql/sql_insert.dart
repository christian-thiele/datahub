import 'package:boost/boost.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class const SqlInsert(
  final SqlQualifiedRelation relation,
  final Map<SqlTypedAttribute, dynamic> values, {
  final List<SqlAttribute> returning = const [],
  final SqlOnConflict? onConflict,
}) with SqlBuilder {
  @override
  Sql toSql() => Sql.join([
    const RawSql('INSERT INTO '),
    relation.toSql(),
    const RawSql(' ('),
    ...values.keys
        .map((e) => e.toSqlUnqualified())
        .separatedBy(const RawSql(', ')),
    const RawSql(') VALUES ('),
    ...values.entries
        .map<Sql>((e) {
          return switch (e.value) {
            final Sql sql => sql,
            _ => ParameterSql(e.value, e.key.type),
          };
        })
        .separatedBy(const RawSql(', ')),
    const RawSql(')'),
    if (onConflict case final onConflict?) const RawSql(' ') + onConflict,
    if (returning.isNotEmpty) const RawSql(' RETURNING '),
    ...returning.cast<Sql>().separatedBy(const RawSql(', ')),
  ]);
}

/// `INSERT INTO relation (columns) <source>` where source is a query.
class const SqlInsertSelect(
  final SqlQualifiedRelation relation,
  final List<SqlAttribute> columns,
  final Sql source, {
  final List<SqlAttribute> returning = const [],
  final SqlOnConflict? onConflict,
}) with SqlBuilder {
  @override
  Sql toSql() => Sql.join([
    const RawSql('INSERT INTO '),
    relation.toSql(),
    const RawSql(' ('),
    ...columns.map((e) => e.toSqlUnqualified()).separatedBy(const RawSql(', ')),
    const RawSql(') '),
    source,
    if (onConflict case final onConflict?) const RawSql(' ') + onConflict,
    if (returning.isNotEmpty) const RawSql(' RETURNING '),
    ...returning.cast<Sql>().separatedBy(const RawSql(', ')),
  ]);
}
