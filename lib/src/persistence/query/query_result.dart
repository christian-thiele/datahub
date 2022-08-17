class QueryResult {
  final String layoutName;
  final Map<String, dynamic> data;

  QueryResult(this.layoutName, this.data);

  static Map<String, dynamic> merge(List<QueryResult> results) {
    final map = <String, dynamic>{};
    for (final result in results) {
      map.addAll(result.data);
    }
    return map;
  }
}
