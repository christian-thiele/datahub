import 'package:boost/boost.dart';

import 'sql_builder.dart';

class CreateSchemaBuilder implements SqlBuilder {
  final String schemaName;

  CreateSchemaBuilder(this.schemaName);

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    return Tuple('CREATE SCHEMA @name', {'name': schemaName});
  }
}
