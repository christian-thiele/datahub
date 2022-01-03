import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';

class UpdateBuilder implements SqlBuilder {
  final String schemaName;
  final String tableName;
  final Map<String, dynamic> _values = {};
  Filter _filter = Filter.empty;

  UpdateBuilder(this.schemaName, this.tableName);

  void values(Map<String, dynamic> entryValues) {
    _values.addAll(entryValues);
  }

  void where(Filter filter) {
    _filter = filter;
  }

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final buffer = StringBuffer();
    final values = _values.entries
        .map((e) =>
            Triple(SqlBuilder.escapeName(e.key), '${e.key}_val', e.value))
        .toList();

    buffer.write('UPDATE $schemaName.$tableName SET '
        '${values.map((e) => '${e.a} = @${e.b}').join(', ')}');

    final substitutionValues =
        Map.fromEntries(values.map((e) => MapEntry(e.b, e.c)));

    if (!_filter.isEmpty) {
      buffer.write(' WHERE ');

      final filterResult = SqlBuilder.filterSql(_filter);
      buffer.write(filterResult.a);
      substitutionValues.addAll(filterResult.b);
    }

    return Tuple(buffer.toString(), substitutionValues);
  }
}
