import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';

import 'select_from.dart';
import 'sql_builder.dart';

class DeleteBuilder implements SqlBuilder {
  final SelectFrom from;
  Filter _filter = Filter.empty;

  DeleteBuilder(this.from);

  void where(Filter filter) {
    _filter = filter;
  }

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final buffer = StringBuffer('DELETE FROM ');
    final values = <String, dynamic>{};

    buffer.write(from.sql);

    if (!_filter.isEmpty) {
      buffer.write(' WHERE ');

      final filterResult = SqlBuilder.filterSql(_filter);
      buffer.write(filterResult.a);
      values.addAll(filterResult.b);
    }

    return Tuple(buffer.toString(),
        values.map((k, v) => MapEntry(k, SqlBuilder.toSqlData(v))));
  }
}
