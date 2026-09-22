import 'package:boost/boost.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class SqlDelete with SqlBuilder {
  final SqlQualifiedRelation relation;
  final Sql? where;
  final Sql? using;
  final List<SqlAttribute> returning;

  SqlDelete(this.relation, this.where, {this.using, this.returning = const []});

  @override
  Sql toSql() => Sql.join([
    RawSql('DELETE FROM '),
    relation.toSql(),
    if (using case final using?) RawSql(' USING ') + using,
    if (where case final where?) RawSql(' WHERE ') + where,
    if (returning.isNotEmpty) RawSql(' RETURNING '),
    ...returning.cast<Sql>().separatedBy(RawSql(', ')),
  ]);
}
