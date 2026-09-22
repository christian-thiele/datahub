import 'package:boost/boost.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class SqlInsert with SqlBuilder {
  final SqlQualifiedRelation relation;
  final Map<SqlTypedAttribute, dynamic> values;
  final List<SqlAttribute> returning;
  final SqlOnConflict? onConflict;

  const SqlInsert(
    this.relation,
    this.values, {
    this.returning = const [],
    this.onConflict,
  });

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
    if (onConflict case final onConflict?) RawSql(' ') + onConflict,
    if (returning.isNotEmpty) RawSql(' RETURNING '),
    ...returning.cast<Sql>().separatedBy(RawSql(', ')),
  ]);
}

/// `INSERT INTO relation (columns) <source>` where source is a query.
class SqlInsertSelect with SqlBuilder {
  final SqlQualifiedRelation relation;
  final List<SqlAttribute> columns;
  final Sql source;
  final List<SqlAttribute> returning;
  final SqlOnConflict? onConflict;

  const SqlInsertSelect(
    this.relation,
    this.columns,
    this.source, {
    this.returning = const [],
    this.onConflict,
  });

  @override
  Sql toSql() => Sql.join([
    RawSql('INSERT INTO '),
    relation.toSql(),
    RawSql(' ('),
    ...columns.map((e) => e.toSqlUnqualified()).separatedBy(RawSql(', ')),
    RawSql(') '),
    source,
    if (onConflict case final onConflict?) RawSql(' ') + onConflict,
    if (returning.isNotEmpty) RawSql(' RETURNING '),
    ...returning.cast<Sql>().separatedBy(RawSql(', ')),
  ]);
}
