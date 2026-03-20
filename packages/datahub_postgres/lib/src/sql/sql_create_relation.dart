import 'package:boost/boost.dart';
import 'package:datahub_postgres/schema.dart';

import 'sql.dart';
import 'sql_attribute_declaration.dart';
import 'sql_qualified_relation.dart';
import 'sql_table_constraint.dart';

class SqlCreateRelation with SqlBuilder {
  final String schemaName;
  final PostgresqlRelation relation;

  SqlCreateRelation(this.schemaName, this.relation);

  @override
  Sql toSql() {
    switch (relation) {
      case final PostgresqlTable relation:
        return Sql.join([
          RawSql('CREATE TABLE '),
          SqlQualifiedRelation(schemaName, relation.name).toSql(),
          RawSql(' ('),
          ...[
            ...relation.attributes.map(
              (e) => SqlAttributeDeclaration(e).toSql(),
            ),
            ...relation.constraints.map((e) => SqlTableConstraint(e).toSql()),
          ].separatedBy(RawSql(', ')),
          RawSql(')'),
        ]);

      case final PostgresqlView relation:
        return Sql.join([
          RawSql('CREATE VIEW '),
          SqlQualifiedRelation(schemaName, relation.name).toSql(),
          RawSql(' AS '),
          relation.select.toSql(),
        ]);

      case final PostgresqlSequence relation:
        return Sql.join([
          RawSql('CREATE SEQUENCE '),
          SqlQualifiedRelation(schemaName, relation.name).toSql(),
        ]);
    }
  }
}
