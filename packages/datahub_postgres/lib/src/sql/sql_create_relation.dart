import 'package:datahub_postgres/datahub_postgres.dart';

class SqlCreateRelation implements SqlBuilder {
  final PostgresqlSchema schema;
  final PostgresqlRelation relation;

  SqlCreateRelation(this.schema, this.relation);

  @override
  Sql toSql() {
    switch (relation) {
      case final PostgresqlTable relation:
        return Sql.combine([
          Sql('CREATE TABLE '),
          SqlQualifiedRelation(schema.name, relation.name).toSql(),
          Sql(' ('),
          relation.attributes
              .map((e) => SqlAttributeDeclaration(e).toSql())
              .joinSql(', '),
          Sql(')'),
        ]);

      case final PostgresqlView relation:
        return Sql.combine([
          Sql('CREATE VIEW '),
          SqlQualifiedRelation(schema.name, relation.name).toSql(),
          Sql(' AS '),
          relation.sql.toSql(),
        ]);
    }
  }
}
