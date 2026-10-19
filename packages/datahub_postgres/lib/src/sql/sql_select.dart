import 'package:boost/boost.dart';
import 'package:datahub_postgres/types.dart';

import 'sql.dart';
import 'sql_attribute.dart';

abstract class const SqlSelectTarget() with SqlBuilder {
  String get name;

  @override
  Sql toSql();
}

class const SqlNestedSelect({
  @override required final String name,
  required final SqlSelect select,
}) extends SqlSelectTarget {
  @override
  Sql toSql() =>
      Sql.join([select.toSql().wrap(), const RawSql(' '), Sql.name(name)]);
}

class const SqlSelect(
  final Sql from,
  final List<SqlAttribute> attributes, {
  final List<SqlAttribute> distinctOn = const <SqlAttribute>[],
  final Sql? where,
  final Sql? group,
  final Sql? order,
  final int limit = -1,
  final int offset = 0,

  /// Locks the selected rows for update until the transaction ends.
  final bool forUpdate = false,

  /// With [forUpdate]: skips rows locked by other transactions instead of
  /// waiting for them.
  final bool skipLocked = false,
}) with SqlBuilder {
  @override
  Sql toSql() {
    return Sql.join([
      const RawSql('SELECT '),
      if (distinctOn.isNotEmpty) ...[
        const RawSql('DISTINCT ON ('),
        ...distinctOn.cast<Sql>().separatedBy(const RawSql(', ')),
        const RawSql(') '),
      ],
      ...attributes.cast<Sql>().separatedBy(const RawSql(', ')),
      const RawSql(' FROM '),
      from,
      if (where case final where?) const RawSql(' WHERE ') + where,
      if (group case final group?) const RawSql(' GROUP BY ') + group,
      if (order case final order?) const RawSql(' ORDER BY ') + order,
      if (offset != 0)
        const RawSql(' OFFSET ') + ParameterSql(offset, const PostgresqlInt()),
      if (limit != -1)
        const RawSql(' LIMIT ') + ParameterSql(limit, const PostgresqlInt()),
      if (forUpdate)
        RawSql(skipLocked ? ' FOR UPDATE SKIP LOCKED' : ' FOR UPDATE'),
    ]);
  }
}
