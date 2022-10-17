import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';

import 'select_from.dart';
import 'sql_builder.dart';

class UpdateBuilder implements SqlBuilder {
  final SelectFrom from;
  final Map<String, dynamic> _values = {};
  Filter _filter = Filter.empty;

  UpdateBuilder(this.from);

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

    buffer.write('UPDATE ');
    buffer.write(from.sql);
    buffer.write(' SET ');
    buffer.write(values
        .map((e) => '${e.a} = ${SqlBuilder.substitutionLiteral(e)}')
        .join(', '));

    final substitutionValues =
        Map.fromEntries(values.map((e) => MapEntry(e.b, e.c)));

    if (!_filter.isEmpty) {
      buffer.write(' WHERE ');

      final filterResult = SqlBuilder.filterSql(_filter);
      buffer.write(filterResult.a);
      substitutionValues.addAll(filterResult.b);
    }

    return Tuple(buffer.toString(),
        substitutionValues.map((k, v) => MapEntry(k, SqlBuilder.toSqlData(v))));
  }
}
