import 'package:boost/boost.dart';

import 'filter.dart';
import 'query_result.dart';
import 'query_select.dart';
import 'query_source.dart';
import 'sort.dart';

class SubQuery extends QuerySource<Map<String, dynamic>> {
  final String alias;

  final QuerySource source;
  final List<QuerySelect> select;
  final Filter filter;
  final List<QuerySelect> distinct;
  final Sort sort;
  final int offset;
  final int limit;

  SubQuery(
    this.source,
    this.select, {
    required this.alias,
    this.filter = Filter.empty,
    this.distinct = const <QuerySelect>[],
    this.sort = Sort.empty,
    this.offset = 0,
    this.limit = -1,
  });

  @override
  Map<String, dynamic>? map(List<QueryResult> results) {
    return results.firstOrNullWhere((e) => e.layoutName == alias)?.data;
  }
}
