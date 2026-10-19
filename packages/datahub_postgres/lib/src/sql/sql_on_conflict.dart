import 'package:boost/boost.dart';
import 'package:datahub_postgres/schema.dart';

import 'sql.dart';
import 'sql_attribute.dart';

/// `ON CONFLICT` clause of an INSERT statement.
sealed class const SqlOnConflict(
  /// Conflict target columns. Must match a unique index or constraint.
  final List<SqlAttribute> target,
) with SqlBuilder {
  const factory doNothing(List<SqlAttribute> target) = SqlOnConflictDoNothing;

  const factory doUpdate(
    List<SqlAttribute> target,
    Map<SqlAttribute, Sql> set, {
    Sql? where,
  }) = SqlOnConflictDoUpdate;

  /// References the value [attribute] would have had, if the conflicting
  /// insert succeeded (`excluded."attribute"`).
  static SqlAttribute excluded(PostgresqlAttribute attribute) =>
      SqlTypedColumnAttribute.of(attribute, relation: 'excluded');

  Sql _targetSql() => target.isEmpty
      ? RawSql.empty
      : const RawSql(' ') +
            Sql.joinWrap(
              target
                  .map((e) => e.toSqlUnqualified())
                  .separatedBy(const RawSql(', ')),
            );
}

final class const SqlOnConflictDoNothing(super.target) extends SqlOnConflict {
  @override
  Sql toSql() => Sql.join([
    const RawSql('ON CONFLICT'),
    _targetSql(),
    const RawSql(' DO NOTHING'),
  ]);
}

final class const SqlOnConflictDoUpdate(
  super.target,
  final Map<SqlAttribute, Sql> set, {
  final Sql? where,
}) extends SqlOnConflict {
  @override
  Sql toSql() => Sql.join([
    const RawSql('ON CONFLICT'),
    _targetSql(),
    const RawSql(' DO UPDATE SET '),
    ...set.entries
        .map((e) => e.key.toSqlUnqualified() + const RawSql(' = ') + e.value)
        .separatedBy(const RawSql(', ')),
    if (where case final where?) const RawSql(' WHERE ') + where,
  ]);
}
