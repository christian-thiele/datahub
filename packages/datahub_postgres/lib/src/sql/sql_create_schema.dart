import 'sql.dart';

class SqlCreateSchema(final String schemaName) with SqlBuilder {
  @override
  Sql toSql() =>
      Sql.join([const RawSql('CREATE SCHEMA '), Sql.name(schemaName)]);
}
