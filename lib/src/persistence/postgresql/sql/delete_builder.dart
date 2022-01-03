import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';

class DeleteBuilder implements SqlBuilder {
  final String schemaName;
  final String tableName;
  Filter _filter = Filter.empty;

  DeleteBuilder(this.schemaName, this.tableName);

  void where(Filter filter) {
    _filter = filter;
  }

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final buffer = StringBuffer('DELETE FROM $schemaName.$tableName');
    final values = <String, dynamic>{};

    if (!_filter.isEmpty) {
      buffer.write(' WHERE ');

      final filterResult = SqlBuilder.filterSql(_filter);
      buffer.write(filterResult.a);
      values.addAll(filterResult.b);
    }

    return Tuple(buffer.toString(), values);
  }
}
