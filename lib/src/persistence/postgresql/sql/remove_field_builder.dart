import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';

import 'sql_builder.dart';

class RemoveFieldBuilder implements SqlBuilder {
  final String schemaName;
  final String tableName;
  final String fieldName;

  RemoveFieldBuilder(this.schemaName, this.tableName, this.fieldName);

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final tableRef =
        '${SqlBuilder.escapeName(schemaName)}.${SqlBuilder.escapeName(tableName)}';
    final colName = SqlBuilder.escapeName(fieldName);

    return Tuple('ALTER TABLE $tableRef DROP COLUMN $colName', {});
  }
}
