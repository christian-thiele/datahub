import 'collection.dart';

class CollectionAdapter<Item> extends Collection<Item> {
  final Future<List<Item>> Function(int offset, int limit) getItemsDelegate;
  final Future<int> Function() getSizeDelegate;

  CollectionAdapter(this.getItemsDelegate, this.getSizeDelegate);

  @override
  Future<List<Item>> getItems(int offset, int limit) =>
      getItemsDelegate(offset, limit);

  @override
  Future<int> getSize() => getSizeDelegate();
}
