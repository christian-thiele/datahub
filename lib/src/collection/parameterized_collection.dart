import 'collection.dart';

abstract class ParameterizedCollection<Item> extends Collection<Item> {
  @override
  Future<List<Item>> getItems(
    int offset,
    int limit, {
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
  });

  @override
  Future<int> getSize({
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
  });
}
