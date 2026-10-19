import 'package:boost/boost.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class SqlDelete(
  final SqlQualifiedRelation relation,
  final Sql? where, {
  final Sql? using,
  final List<SqlAttribute> returning = const [],
}) with SqlBuilder {
  @override
  Sql toSql() => Sql.join([
    const RawSql('DELETE FROM '),
    relation.toSql(),
    if (using case final using?) const RawSql(' USING ') + using,
    if (where case final where?) const RawSql(' WHERE ') + where,
    if (returning.isNotEmpty) const RawSql(' RETURNING '),
    ...returning.cast<Sql>().separatedBy(const RawSql(', ')),
  ]);
}
