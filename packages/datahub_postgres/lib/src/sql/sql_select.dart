import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/types.dart';

import 'sql_attribute.dart';
import 'sql.dart';

abstract class SqlSelectTarget with SqlBuilder {
  const SqlSelectTarget();

  String get name;

  @override
  Sql toSql();
}

class SqlNestedSelect extends SqlSelectTarget {
  @override
  final String name;
  final SqlSelect select;

  const SqlNestedSelect({required this.name, required this.select});

  @override
  Sql toSql() =>
      Sql.join([select.toSql()..wrap(), RawSql(' '), Sql.name(name)]);
}

class SqlSelect with SqlBuilder {
  final Sql from;
  final List<SqlAttribute> attributes;
  final SqlAttribute? distinctOn;
  final Sql? where;
  final Sql? group;
  final Sql? order;
  final int limit;
  final int offset;

  const SqlSelect(
    this.from,
    this.attributes, {
    this.distinctOn,
    this.where,
    this.group,
    this.order,
    this.limit = -1,
    this.offset = 0,
  });

  @override
  Sql toSql() {
    return Sql.join([
      RawSql('SELECT '),
      if (distinctOn case final distinctOn?)
        RawSql('DISTINCT ON (') + distinctOn + RawSql(') '),
      ...attributes.cast<Sql>().separatedBy(RawSql(', ')),
      RawSql(' FROM '),
      from,
      if (where case final where?) RawSql(' WHERE ') + where,
      if (group case final group?) RawSql(' GROUP BY ') + group,
      if (order case final order?) RawSql(' ORDER BY ') + order,
      if (offset != 0)
        RawSql(' OFFSET ') + ParameterSql(offset, PostgresqlInt()),
      if (limit != -1) RawSql(' LIMIT ') + ParameterSql(limit, PostgresqlInt()),
    ]);
  }
}
