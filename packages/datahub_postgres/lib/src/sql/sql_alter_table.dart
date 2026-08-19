import 'package:boost/boost.dart';
import 'package:datahub_postgres/schema.dart';

import 'sql.dart';
import 'sql_qualified_relation.dart';

/// `ALTER TABLE <relation> <action>[, <action>]`.
class SqlAlterTable with SqlBuilder {
  final String schemaName;
  final String name;
  final List<SqlAlterTableAction> actions;

  const SqlAlterTable({
    required this.schemaName,
    required this.name,
    required this.actions,
  });

  @override
  Sql toSql() => Sql.join([
    RawSql('ALTER TABLE '),
    SqlQualifiedRelation(schemaName, name).toSql(),
    RawSql(' '),
    ...actions.map((e) => e.toSql()).separatedBy(RawSql(', ')),
  ]);
}

sealed class SqlAlterTableAction {
  const SqlAlterTableAction();

  Sql toSql();
}

final class SqlAddColumn extends SqlAlterTableAction {
  final AttributeSnapshot attribute;

  const SqlAddColumn(this.attribute);

  @override
  Sql toSql() =>
      Sql.join([RawSql('ADD COLUMN '), attribute.toDeclarationSql()]);
}

final class SqlDropColumn extends SqlAlterTableAction {
  final String name;

  const SqlDropColumn(this.name);

  @override
  Sql toSql() => RawSql('DROP COLUMN ${Sql.escapeName(name)}');
}

final class SqlAlterColumnType extends SqlAlterTableAction {
  final String name;
  final String type;

  const SqlAlterColumnType(this.name, this.type);

  @override
  Sql toSql() => RawSql(
    'ALTER COLUMN ${Sql.escapeName(name)} TYPE $type '
    'USING ${Sql.escapeName(name)}::$type',
  );
}

final class SqlAlterColumnNotNull extends SqlAlterTableAction {
  final String name;
  final bool notNull;

  const SqlAlterColumnNotNull(this.name, this.notNull);

  @override
  Sql toSql() => RawSql(
    'ALTER COLUMN ${Sql.escapeName(name)} '
    '${notNull ? 'SET' : 'DROP'} NOT NULL',
  );
}

final class SqlAlterColumnDefault extends SqlAlterTableAction {
  final String name;

  /// The new default as literal SQL, or `null` to drop the default.
  final String? defaultValue;

  const SqlAlterColumnDefault(this.name, this.defaultValue);

  @override
  Sql toSql() => RawSql(
    'ALTER COLUMN ${Sql.escapeName(name)} '
    '${defaultValue == null ? 'DROP DEFAULT' : 'SET DEFAULT $defaultValue'}',
  );
}

final class SqlAddTableConstraint extends SqlAlterTableAction {
  final TableConstraintSnapshot constraint;

  const SqlAddTableConstraint(this.constraint);

  @override
  Sql toSql() => Sql.join([RawSql('ADD '), constraint.toDeclarationSql()]);
}

final class SqlDropTableConstraint extends SqlAlterTableAction {
  final String name;

  const SqlDropTableConstraint(this.name);

  @override
  Sql toSql() => RawSql('DROP CONSTRAINT ${Sql.escapeName(name)}');
}
