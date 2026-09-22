import 'package:boost/boost.dart';
import 'package:datahub_postgres/schema.dart';

import 'sql.dart';
import 'sql_attribute.dart';

/// `ON CONFLICT` clause of an INSERT statement.
sealed class SqlOnConflict with SqlBuilder {
  /// Conflict target columns. Must match a unique index or constraint.
  final List<SqlAttribute> target;

  const SqlOnConflict(this.target);

  const factory SqlOnConflict.doNothing(List<SqlAttribute> target) =
      SqlOnConflictDoNothing;

  const factory SqlOnConflict.doUpdate(
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
      : RawSql(' ') +
            Sql.joinWrap(
              target.map((e) => e.toSqlUnqualified()).separatedBy(RawSql(', ')),
            );
}

final class SqlOnConflictDoNothing extends SqlOnConflict {
  const SqlOnConflictDoNothing(super.target);

  @override
  Sql toSql() =>
      Sql.join([RawSql('ON CONFLICT'), _targetSql(), RawSql(' DO NOTHING')]);
}

final class SqlOnConflictDoUpdate extends SqlOnConflict {
  final Map<SqlAttribute, Sql> set;
  final Sql? where;

  const SqlOnConflictDoUpdate(super.target, this.set, {this.where});

  @override
  Sql toSql() => Sql.join([
    RawSql('ON CONFLICT'),
    _targetSql(),
    RawSql(' DO UPDATE SET '),
    ...set.entries
        .map((e) => e.key.toSqlUnqualified() + RawSql(' = ') + e.value)
        .separatedBy(RawSql(', ')),
    if (where case final where?) RawSql(' WHERE ') + where,
  ]);
}
