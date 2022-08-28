import 'parameterized_collection.dart';

class ParamWrapper<Item> extends ParameterizedCollection<Item> {
  final ParameterizedCollection<Item> internal;
  Map<String, dynamic> defaultParams;
  Map<String, String?> defaultQuery;

  ParamWrapper(
    this.internal, {
    this.defaultParams = const {},
    this.defaultQuery = const {},
  });

  @override
  Future<List<Item>> getItems(
    int offset,
    int limit, {
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
  }) async {
    return await internal.getItems(
      offset,
      limit,
      params: _params(params),
      query: _query(query),
    );
  }

  @override
  Future<int> getSize({
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
  }) async {
    return await internal.getSize(
      params: _params(params),
      query: _query(query),
    );
  }

  void setParams(Map<String, dynamic> params) => defaultParams = params;

  void setQuery(Map<String, String?> query) => defaultQuery = query;

  Map<String, dynamic> _params(Map<String, dynamic> params) =>
      Map.of(defaultParams)..addAll(params);

  Map<String, String?> _query(Map<String, String?> query) =>
      Map.of(defaultQuery)..addAll(query);
}
