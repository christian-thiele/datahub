import 'param_sql.dart';
import 'sql_builder.dart';

class RemoveTableBuilder implements SqlBuilder {
  final String schemaName;
  final String tableName;

  RemoveTableBuilder(this.schemaName, this.tableName);

  @override
  ParamSql buildSql() {
    final tableRef =
        '${SqlBuilder.escapeName(schemaName)}.${SqlBuilder.escapeName(tableName)}';
    return ParamSql('DROP TABLE $tableRef');
  }
}
