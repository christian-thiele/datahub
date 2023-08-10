import 'dart:async';

import 'package:datahub/api.dart';
import 'package:datahub/hub.dart';
import 'package:datahub/rest_client.dart';
import 'package:datahub/src/collection/collection_window_state.dart';
import 'package:datahub/transfer_object.dart';

typedef WindowDelegate<Item extends TransferObjectBase<Id>, Id>
    = Stream<CollectionWindowState<Item, Id>> Function(
  int offset,
  int limit, {
  CollectionWindowState<Item, Id>? previous,
  Map<String, String> params,
  Map<String, List<String>> query,
});

//TODO docs
abstract class ReactiveCollection<Item extends TransferObjectBase<Id>, Id> {
  factory ReactiveCollection.delegate(WindowDelegate<Item, Id> getWindow) =>
      _ReactiveCollectionAdapter(getWindow);

  factory ReactiveCollection.rest(
    RestClient client,
    String endpoint,
    TransferBean<Item> bean, {
    Map<String, String> params = const {},
    Map<String, List<String>> query = const {},
  }) =>
      CollectionResourceRestClient(
        client,
        RoutePattern(endpoint),
        bean,
        defaultParams: params,
        defaultQuery: query,
      );

  Stream<CollectionWindowState<Item, Id>> getWindow(
    int offset,
    int limit, {
    CollectionWindowState<Item, Id>? previous,
    Map<String, String> params = const {},
    Map<String, List<String>> query = const {},
  });
}

extension ReactiveCollectionMapperExtension<Item extends TransferObjectBase<Id>,
    Id> on ReactiveCollection<Item, Id> {
  ReactiveCollection<Target, TargetId>
      map<Target extends TransferObjectBase<TargetId>, TargetId>(
              FutureOr<Target> Function(Item) mapper) =>
          _ReactiveCollectionMapper(this, mapper);
}

class _ReactiveCollectionAdapter<Item extends TransferObjectBase<Id>, Id>
    implements ReactiveCollection<Item, Id> {
  final WindowDelegate<Item, Id> _getWindow;

  _ReactiveCollectionAdapter(this._getWindow);

  @override
  Stream<CollectionWindowState<Item, Id>> getWindow(int offset, int limit,
          {CollectionWindowState<Item, Id>? previous,
          Map<String, String> params = const {},
          Map<String, List<String>> query = const {}}) =>
      _getWindow(
        offset,
        limit,
        previous: previous,
        params: params,
        query: query,
      );
}

class _ReactiveCollectionMapper<
    Source extends TransferObjectBase<SourceId>,
    SourceId,
    Target extends TransferObjectBase<TargetId>,
    TargetId> implements ReactiveCollection<Target, TargetId> {
  final ReactiveCollection<Source, SourceId> source;
  final FutureOr<Target> Function(Source) mapper;

  _ReactiveCollectionMapper(this.source, this.mapper);

  @override
  Stream<CollectionWindowState<Target, TargetId>> getWindow(
      int offset, int limit,
      {CollectionWindowState<Target, TargetId>? previous,
      Map<String, String> params = const {},
      Map<String, List<String>> query = const {}}) {
    //TODO previous window?
    return source
        .getWindow(offset, limit, params: params, query: query)
        .asyncMap(_mapState);
  }

  FutureOr<CollectionWindowState<Target, TargetId>> _mapState(
      CollectionWindowState<Source, SourceId> state) async {
    return CollectionWindowState(
      state.length,
      state.windowOffset,
      await Stream.fromIterable(state.window).asyncMap(mapper).toList(),
    );
  }
}
