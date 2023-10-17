import 'package:postgres/postgres.dart';

import 'param_sql.dart';
import 'sql_builder.dart';

class CreateSchemaBuilder implements SqlBuilder {
  final String schemaName;

  CreateSchemaBuilder(this.schemaName);

  @override
  ParamSql buildSql() {
    final sql = ParamSql('CREATE SCHEMA ');
    sql.addParam(schemaName, PostgreSQLDataType.text);
    return sql;
  }
}
