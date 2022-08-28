import 'collection.dart';

abstract class ParameterizedCollection<Item> extends Collection<Item> {
  @override
  Future<List<Item>> getItems(int offset, int limit,
      {Map<String, dynamic>? params, Map<String, String?>? query});

  @override
  Future<int> getSize(
      {Map<String, dynamic>? params, Map<String, String?>? query});
}
