import 'package:boost/boost.dart';
import 'package:datahub_postgres/schema.dart';

import 'sql.dart';
import 'sql_qualified_relation.dart';

/// `CREATE TABLE` / `CREATE VIEW` / `CREATE SEQUENCE` for a [RelationSnapshot].
///
/// Relations are rendered from their snapshot rather than from the live schema
/// model, so that a relation created at startup and the same relation created
/// by a migration are guaranteed to produce identical DDL.
class SqlCreateRelation with SqlBuilder {
  final RelationSnapshot relation;

  /// Whether `IF NOT EXISTS` is added.
  ///
  /// Used where two processes can legitimately race to create the same
  /// relation - the migration tracking table is created by whichever instance
  /// gets there first. Views do not support it and ignore the flag.
  final bool ifNotExists;

  const SqlCreateRelation(this.relation, {this.ifNotExists = false});

  SqlCreateRelation.of(PostgresqlRelation relation, {bool ifNotExists = false})
    : this(RelationSnapshot.of(relation), ifNotExists: ifNotExists);

  @override
  Sql toSql() {
    final name = SqlQualifiedRelation(
      relation.schemaName,
      relation.name,
    ).toSql();

    switch (relation) {
      case final TableSnapshot relation:
        return Sql.join([
          RawSql('CREATE TABLE '),
          if (ifNotExists) RawSql('IF NOT EXISTS '),
          name,
          RawSql(' ('),
          ...[
            ...relation.attributes.map((e) => e.toDeclarationSql()),
            ...relation.constraints.map((e) => e.toDeclarationSql()),
          ].separatedBy(RawSql(', ')),
          RawSql(')'),
        ]);

      case final ViewSnapshot relation:
        return Sql.join([
          RawSql('CREATE VIEW '),
          name,
          RawSql(' AS '),
          RawSql(relation.select),
        ]);

      case SequenceSnapshot():
        return Sql.join([
          RawSql('CREATE SEQUENCE '),
          if (ifNotExists) RawSql('IF NOT EXISTS '),
          name,
        ]);
    }
  }
}
