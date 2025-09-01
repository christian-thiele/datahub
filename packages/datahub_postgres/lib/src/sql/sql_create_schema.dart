import 'package:datahub_postgres/schema.dart';

import 'sql.dart';

class SqlCreateSchema implements SqlBuilder {
  final PostgresqlSchema schema;

  SqlCreateSchema(this.schema);

  @override
  Sql toSql() => Sql('CREATE SCHEMA ${Sql.escapeName(schema.name)}');
}
