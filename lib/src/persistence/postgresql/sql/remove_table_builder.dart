import 'package:boost/boost.dart';

import 'sql_builder.dart';

class RemoveTableBuilder implements SqlBuilder {
  final String schemaName;
  final String tableName;

  RemoveTableBuilder(this.schemaName, this.tableName);

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final tableRef =
        '${SqlBuilder.escapeName(schemaName)}.${SqlBuilder.escapeName(tableName)}';
    return Tuple('DROP TABLE $tableRef', {});
  }
}
