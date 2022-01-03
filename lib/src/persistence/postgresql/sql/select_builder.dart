import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';

class SelectBuilder implements SqlBuilder {
  final String schemaName;
  final String tableName;
  Filter _filter = Filter.empty;
  Sort _sort = Sort.empty;
  List<QuerySelect>? _select;
  int _limit = -1;
  int _offset = 0;

  SelectBuilder(this.schemaName, this.tableName);

  void select(List<QuerySelect> selections) {
    _select = selections;
  }

  void offset(int value) {
    _offset = value;
  }

  void limit(int value) {
    _limit = value;
  }

  void where(Filter filter) {
    _filter = filter;
  }

  void orderBy(Sort sort) {
    _sort = sort;
  }

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final buffer = StringBuffer('SELECT ');
    final values = <String, dynamic>{};

    if (_select?.isNotEmpty ?? false) {
      final selectResults = _select!.map((s) => SqlBuilder.selectSql(s));
      buffer.write(selectResults.map((e) => e.a).join(', '));
      values.addEntries(selectResults.expand((s) => s.b.entries));
      buffer.write(' ');
    } else {
      buffer.write('* ');
    }

    buffer.write('FROM $schemaName.$tableName');

    if (!_filter.isEmpty) {
      buffer.write(' WHERE ');

      final filterResult = SqlBuilder.filterSql(_filter);
      buffer.write(filterResult.a);
      values.addAll(filterResult.b);
    }

    if (!_sort.isEmpty) {
      buffer.write(' ORDER BY ');

      final sortResult = SqlBuilder.sortSql(_sort);
      buffer.write(sortResult.a);
      values.addAll(sortResult.b);
    }

    if (_offset > 0) {
      buffer.write(' OFFSET $_offset');
    }

    if (_limit > -1) {
      buffer.write(' LIMIT $_limit');
    }

    return Tuple(buffer.toString(), values);
  }
}
