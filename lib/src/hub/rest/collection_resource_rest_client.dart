import 'dart:async';

import 'package:datahub/hub.dart';
import 'package:datahub/rest_client.dart';
import 'package:datahub/transfer_object.dart';

import '../transport/client_collection_resource_stream_controller.dart';

class CollectionResourceRestClient<T extends TransferObjectBase<TId>, TId>
    extends CollectionResourceClient<T, TId> with _ImmutableResourceMethods {
  @override
  final RestClient client;

  @override
  final Map<String, String> routeParams;

  CollectionResourceRestClient(
    this.client,
    super.routePattern,
    super.bean,
    this.routeParams,
  );
}

mixin _ImmutableResourceMethods<T extends TransferObjectBase<TId>, TId>
    on CollectionResourceClient<T, TId> {
  RestClient get client;

  Map<String, String> get routeParams;

  final _streamControllers =
      <ClientCollectionResourceStreamController<T, TId>>[];

  ClientCollectionResourceStreamController<T, TId> _getController(
      Map<String, String> params, Map<String, String> query) {
    final controller = ClientCollectionResourceStreamController<T, TId>(
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
  Stream<CollectionState<T, TId>> getWindow(int offset, int length,
          {CollectionState? previous, Map<String, String> query = const {}}) =>
      _getController(routeParams, {
        ...query,
        'offset': offset.toString(),
        'length': length.toString(),
      }).stream;
}
