import 'parameterized_collection.dart';

class ParamWrapper<Item> extends ParameterizedCollection<Item> {
  final ParameterizedCollection<Item> internal;
  Map<String, dynamic>? defaultParams;
  Map<String, String?>? defaultQuery;

  ParamWrapper(this.internal, {this.defaultParams, this.defaultQuery});

  @override
  Future<List<Item>> getItems(int offset, int limit,
      {Map<String, dynamic>? params, Map<String, String?>? query}) async =>
      await internal.getItems(offset, limit,
          params: _params(params), query: _query(query));

  @override
  Future<int> getSize(
      {Map<String, dynamic>? params, Map<String, String?>? query}) async =>
      await internal.getSize(params: _params(params), query: _query(query));

  void setParams(Map<String, dynamic>? params) => defaultParams = params;

  void setQuery(Map<String, String?>? query) => defaultQuery = query;

  Map<String, dynamic>? _params(Map<String, dynamic>? params) {
    if (params != null && defaultParams != null) {
      return Map.of(defaultParams!)..addAll(params);
    } else {
      return defaultParams ?? params;
    }
  }

  Map<String, String?>? _query(Map<String, String?>? query) {
    if (query != null && defaultQuery != null) {
      return Map.of(defaultQuery!)..addAll(query);
    } else {
      return defaultQuery ?? query;
    }
  }
}
