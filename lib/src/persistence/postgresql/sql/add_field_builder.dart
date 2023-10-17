import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/src/persistence/postgresql/postgresql_data_types.dart';

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
  Tuple<String, Map<String, dynamic>> buildSql() {
    final tableRef =
        '${SqlBuilder.escapeName(schemaName)}.${SqlBuilder.escapeName(tableName)}';
    final colName = SqlBuilder.escapeName(field.name);

    final buffer = StringBuffer(
        'ALTER TABLE $tableRef ADD COLUMN $colName ${type.getTypeSql(field.type)}');
    final subs = <String, dynamic>{};

    if (field is PrimaryKey) {
      buffer.write(' PRIMARY KEY');
    }

    if (initialValue != null) {
      final sql = SqlBuilder.expressionSql(initialValue);
      buffer.write('; UPDATE $tableRef SET $colName = $sql');
    }

    if (field is! PrimaryKey && !field.nullable) {
      buffer
          .write('; ALTER TABLE $tableRef ALTER COLUMN $colName SET NOT NULL');
    }

    return Tuple(buffer.toString(), subs);
  }
}
