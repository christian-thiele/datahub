import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';

import 'sql_builder.dart';

//TODO complete select
class SelectBuilder implements SqlBuilder {
  final String schemaName;
  final String tableName;
  Filter _filter = Filter.empty;

  SelectBuilder(this.schemaName, this.tableName);

  void where(Filter filter) {
    _filter = filter;
  }

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final buffer = StringBuffer('SELECT ');
    final values = <String, dynamic>{};

    //TODO columns
    buffer.write('* ');

    buffer.write('FROM $schemaName.$tableName');

    if (!_filter.isEmpty) {
      buffer.write(' WHERE ');

      final filterResult = SqlBuilder.filterSql(_filter);
      buffer.write(filterResult.a);
      values.addAll(filterResult.b);
    }

    return Tuple(buffer.toString(), values);
  }
}
