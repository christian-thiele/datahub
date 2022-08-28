import 'dart:async';

import 'collection_mapper.dart';

/// Interface for collections.
///
/// See [CollectionController] for details.
abstract class Collection<Item> {
  Future<int> getSize();

  Future<List<Item>> getItems(int offset, int limit);

  CollectionMapper<Item, T> map<T>(FutureOr<T> Function(Item) mapper) =>
      CollectionMapper(this, mapper);
}
