import 'package:boost/boost.dart';

import 'sql_builder.dart';

class InsertBuilder implements SqlBuilder {
  final String schemaName;
  final String tableName;
  final Map<String, dynamic> _values = {};
  String? _returning;

  InsertBuilder(this.schemaName, this.tableName);

  void values(Map<String, dynamic> entryValues) {
    _values.addAll(entryValues);
  }

  void returning(String? expr) {
    _returning = expr;
  }

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final buffer = StringBuffer();
    final values = _values.entries
        .map((e) =>
            Triple(SqlBuilder.escapeName(e.key), '${e.key}_val', e.value))
        .toList();

    buffer.write('INSERT INTO $schemaName.$tableName '
        '(${values.map((e) => e.a).join(', ')}) '
        'VALUES (${values.map((e) => '@${e.b}').join(', ')})');

    if (_returning != null) {
      buffer.write(' RETURNING $_returning');
    }

    return Tuple(buffer.toString(),
        Map.fromEntries(values.map((e) => MapEntry(e.b, e.c))));
  }
}
