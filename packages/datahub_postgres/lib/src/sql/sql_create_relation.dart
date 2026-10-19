import 'package:boost/boost.dart';
import 'package:datahub_postgres/schema.dart';

import 'sql.dart';
import 'sql_attribute_declaration.dart';
import 'sql_qualified_relation.dart';
import 'sql_table_constraint.dart';

class SqlCreateRelation(
  final String schemaName,
  final PostgresqlRelation relation,
) with SqlBuilder {
  @override
  Sql toSql() {
    switch (relation) {
      case final PostgresqlTable relation:
        return Sql.join([
          const RawSql('CREATE TABLE '),
          SqlQualifiedRelation(schemaName, relation.name).toSql(),
          const RawSql(' ('),
          ...[
            ...relation.attributes.map(
              (e) => SqlAttributeDeclaration(e).toSql(),
            ),
            ...relation.constraints.map((e) => SqlTableConstraint(e).toSql()),
          ].separatedBy(const RawSql(', ')),
          const RawSql(')'),
        ]);

      case final PostgresqlView relation:
        return Sql.join([
          const RawSql('CREATE VIEW '),
          SqlQualifiedRelation(schemaName, relation.name).toSql(),
          const RawSql(' AS '),
          relation.select.toSql(),
        ]);

      case final PostgresqlSequence relation:
        return Sql.join([
          const RawSql('CREATE SEQUENCE '),
          SqlQualifiedRelation(schemaName, relation.name).toSql(),
        ]);
    }
  }
}
