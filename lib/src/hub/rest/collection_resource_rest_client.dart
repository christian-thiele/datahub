import 'dart:async';

import 'package:datahub/collection.dart';
import 'package:datahub/hub.dart';
import 'package:datahub/rest_client.dart';
import 'package:datahub/transfer_object.dart';

import '../transport/client_collection_resource_stream_controller.dart';

class CollectionResourceRestClient<Item extends TransferObjectBase<Id>, Id>
    extends CollectionResourceClient<Item, Id> with _ImmutableResourceMethods {
  @override
  final RestClient client;

  @override
  final Map<String, String> defaultParams;

  @override
  final Map<String, List<String>> defaultQuery;

  CollectionResourceRestClient(
    this.client,
    super.routePattern,
    super.bean, {
    this.defaultParams = const {},
    this.defaultQuery = const {},
  });
}

mixin _ImmutableResourceMethods<Item extends TransferObjectBase<Id>, Id>
    on CollectionResourceClient<Item, Id> {
  RestClient get client;

  Map<String, String> get defaultParams;

  Map<String, List<String>> get defaultQuery;

  final _streamControllers =
      <ClientCollectionResourceStreamController<Item, Id>>[];

  ClientCollectionResourceStreamController<Item, Id> _getController(
      Map<String, String> params, Map<String, List<String>> query) {
    final controller = ClientCollectionResourceStreamController<Item, Id>(
      client,
      routePattern,
      params,
      query,
      bean,
    );
    _streamControllers.add(controller);
    return controller;
  }

  @override
  Stream<CollectionWindowState<Item, Id>> getWindow(
    int offset,
    int length, {
    CollectionWindowState<Item, Id>? previous,
    Map<String, String> params = const {},
    Map<String, List<String>> query = const {},
  }) =>
      _getController({
        ...defaultParams,
        ...params,
      }, {
        ...defaultQuery,
        ...query,
        'offset': [offset.toString()],
        'length': [length.toString()],
      }).stream.transform(CollectionWindowStateStreamTransformer());
}
