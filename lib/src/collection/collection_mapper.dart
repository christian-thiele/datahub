import 'dart:async';

import 'collection.dart';

/// Maps collection elements while querying.
class CollectionMapper<InternalItem, Item> extends Collection<Item> {
  final Collection<InternalItem> internal;
  final FutureOr<Item> Function(InternalItem) mapper;

  CollectionMapper(this.internal, this.mapper);

  @override
  Future<List<Item>> getItems(int offset, int limit) async {
    final items = await internal.getItems(offset, limit);
    final result = <Item>[];
    for (final item in items) {
      result.add(await mapper(item));
    }
    return result;
  }

  @override
  Future<int> getSize() async => await internal.getSize();
}
