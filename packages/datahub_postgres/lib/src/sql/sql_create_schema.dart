import 'package:datahub_postgres/schema.dart';

import 'sql.dart';

class SqlCreateSchema with SqlBuilder {
  final String schemaName;

  SqlCreateSchema(this.schemaName);

  @override
  Sql toSql() => Sql.join([RawSql('CREATE SCHEMA '), Sql.name(schemaName)]);
}
