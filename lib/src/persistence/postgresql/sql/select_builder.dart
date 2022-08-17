import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';

import 'select_from.dart';
import 'sql_builder.dart';

class SelectBuilder implements SqlBuilder {
  final SelectFrom from;
  Filter _filter = Filter.empty;
  Sort _sort = Sort.empty;
  List<QuerySelect>? _select;
  List<QuerySelect>? _distinct;
  int _limit = -1;
  int _offset = 0;

  SelectBuilder(this.from);

  void select(List<QuerySelect> selections) {
    _select = selections;
  }

  void distinct(List<QuerySelect>? distinct) {
    _distinct = distinct;
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

    if (_distinct?.isNotEmpty ?? false) {
      buffer.write('DISTINCT ON (');
      final selectResults = _distinct!.map((s) => SqlBuilder.selectSql(s));
      buffer.write(selectResults.map((e) => e.a).join(', '));
      buffer.write(') ');
    }

    if (_select?.isNotEmpty ?? false) {
      final selectResults = _select!.map((s) => SqlBuilder.selectSql(s));
      buffer.write(selectResults.map((e) => e.a).join(', '));
      values.addEntries(selectResults.expand((s) => s.b.entries));
      buffer.write(' ');
    } else {
      buffer.write('* ');
    }

    buffer.write('FROM ');
    buffer.write(from.sql);

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
