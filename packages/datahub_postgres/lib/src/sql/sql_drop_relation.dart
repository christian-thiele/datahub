import 'package:datahub_postgres/schema.dart';

import 'sql.dart';
import 'sql_qualified_relation.dart';

/// `DROP TABLE` / `DROP VIEW` / `DROP SEQUENCE`.
class SqlDropRelation with SqlBuilder {
  final String schemaName;
  final String name;
  final String kind;
  final bool ifExists;

  const SqlDropRelation({
    required this.schemaName,
    required this.name,
    required this.kind,
    this.ifExists = false,
  });

  SqlDropRelation.of(RelationSnapshot relation, {bool ifExists = false})
    : this(
        schemaName: relation.schemaName,
        name: relation.name,
        kind: relation.kind,
        ifExists: ifExists,
      );

  @override
  Sql toSql() => Sql.join([
    RawSql('DROP ${kind.toUpperCase()} '),
    if (ifExists) RawSql('IF EXISTS '),
    SqlQualifiedRelation(schemaName, name).toSql(),
  ]);
}
