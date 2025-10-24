import 'package:boost/boost.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

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
          ...relation.attributes
              .map((e) => SqlAttributeDeclaration(e).toSql())
              .separatedBy(RawSql(', ')),
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
