import 'package:datahub/persistence.dart';
import 'package:datahub/src/persistence/postgresql/postgresql_data_types.dart';

import 'param_sql.dart';
import 'sql_builder.dart';

class AddFieldBuilder implements SqlBuilder {
  final String schemaName;
  final String tableName;
  final PostgresqlDataType type;
  final DataField field;
  final dynamic initialValue;

  AddFieldBuilder(
    this.schemaName,
    this.tableName,
    this.field,
    this.type,
    this.initialValue,
  ) {
    if (!field.nullable && initialValue == null) {
      throw PersistenceException(
          'Cannot add non-nullable field without initial value!');
    }
  }

  @override
  ParamSql buildSql() {
    final tableRef =
        '${SqlBuilder.escapeName(schemaName)}.${SqlBuilder.escapeName(tableName)}';
    final colName = SqlBuilder.escapeName(field.name);

    final sql = ParamSql(
        'ALTER TABLE $tableRef ADD COLUMN $colName ${type.getTypeSql(field.type)}');

    if (field is PrimaryKey) {
      sql.addSql(' PRIMARY KEY');
    }

    if (initialValue != null) {
      sql.addSql('; UPDATE $tableRef SET $colName = ');
      sql.add(SqlBuilder.expressionSql(initialValue));
    }

    if (field is! PrimaryKey && !field.nullable) {
      sql.addSql('; ALTER TABLE $tableRef ALTER COLUMN $colName SET NOT NULL');
    }

    return sql;
  }
}
