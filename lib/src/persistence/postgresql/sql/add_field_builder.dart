import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';

import 'sql_builder.dart';

class AddFieldBuilder implements SqlBuilder {
  final String schemaName;
  final String tableName;
  final DataField field;
  final dynamic initialValue;

  AddFieldBuilder(this.schemaName, this.tableName, this.field,
      {this.initialValue}) {
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
        'ALTER TABLE $tableRef ADD COLUMN $colName ${SqlBuilder.typeSql(field)}');
    final subs = <String, dynamic>{};

    if (field is PrimaryKey) {
      buffer.write(' PRIMARY KEY');
    }

    if (initialValue != null) {
      buffer.write('; UPDATE $tableRef SET $colName = @init');
      subs['init'] = initialValue;
    }

    if (field is! PrimaryKey && !field.nullable) {
      buffer
          .write('; ALTER TABLE $tableRef ALTER COLUMN $colName SET NOT NULL');
    }

    return Tuple(buffer.toString(), subs);
  }
}
