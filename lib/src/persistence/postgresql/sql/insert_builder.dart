import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';

import '../type_registry.dart';
import 'sql_builder.dart';

class InsertBuilder implements SqlBuilder {
  final TypeRegistry typeRegistry;
  final String schemaName;
  final String tableName;
  final Map<DataField, dynamic> _values = {};
  String? _returning;

  InsertBuilder(this.typeRegistry, this.schemaName, this.tableName);

  void values(Map<DataField, dynamic> entryValues) {
    _values.addAll(entryValues);
  }

  void returning(String? expr) {
    _returning = expr;
  }

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final buffer = StringBuffer();
    final values = _values.entries.map((e) {
      final fieldName = SqlBuilder.escapeName(e.key.name);
      final type = typeRegistry.findType(e.key.type);
      final value = type.toPostgresValue(e.value);
      return Tuple(fieldName, value);
    }).toList();

    buffer.write('INSERT INTO $schemaName.$tableName '
        '(${values.map((e) => e.a).join(', ')}) '
        'VALUES (${values.map((e) => e.b).join(', ')})');

    if (_returning != null) {
      buffer.write(' RETURNING $_returning');
    }

    return Tuple(
        buffer.toString(),
        Map.fromEntries(
            values.map((e) => MapEntry(e.b, SqlBuilder.toSqlData(e.b)))));
  }
}
