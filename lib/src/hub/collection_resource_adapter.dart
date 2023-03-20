import 'dart:async';

import 'package:datahub/api.dart';
import 'package:datahub/transfer_object.dart';

import 'collection_resource.dart';

class CollectionResourceAdapter<T extends TransferObjectBase<TId>, TId>
    extends CollectionResourceProvider<T, TId> {
  final Stream<CollectionEvent<T, TId>> Function(
      ApiRequest request, int offset, int length) _getWindow;

  CollectionResourceAdapter(
    super.routePattern,
    super.bean,
    this._getWindow,
  );

  @override
  Stream<CollectionEvent<T, TId>> getWindow(
          ApiRequest request, int offset, int length) =>
      _getWindow(request, offset, length);
}
