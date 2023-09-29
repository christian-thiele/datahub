//TODO collations, constraints, ...
//maybe even inheritance
import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';

import 'sql_builder.dart';

class CreateTableBuilder implements SqlBuilder {
  final bool ifNotExists;
  final String schemaName;
  final String tableName;
  final List<DataField> fields = [];

  CreateTableBuilder(this.schemaName, this.tableName,
      {this.ifNotExists = false});

  factory CreateTableBuilder.fromLayout(DataSchema schema, DataBean bean) {
    return CreateTableBuilder(schema.name, bean.layoutName, ifNotExists: true)
      ..fields.addAll(bean.fields);
  }

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final buffer = StringBuffer('CREATE TABLE ');

    if (ifNotExists) {
      buffer.write('IF NOT EXISTS ');
    }

    buffer.write(
        '${SqlBuilder.escapeName(schemaName)}.${SqlBuilder.escapeName(tableName)} (');

    buffer.write(fields.map(_createFieldSql).join(','));

    buffer.write(')');

    return Tuple(buffer.toString(), {});
  }

  String _createFieldSql(DataField field) {
    final buffer = StringBuffer(SqlBuilder.escapeName(field.name));
    buffer.write(' ${SqlBuilder.typeSql(field)}');
    if (field is PrimaryKey) {
      buffer.write(' PRIMARY KEY');
    } else if (!field.nullable) {
      buffer.write(' NOT NULL');
    }
    //TODO foreign key?
    return buffer.toString();
  }
}
