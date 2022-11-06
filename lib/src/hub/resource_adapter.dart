import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub/src/hub/resource.dart';

class ResourceAdapter<T extends TransferObjectBase>
    extends ResourceProvider<T> {
  final Future<T> Function(ApiRequest request) _get;
  final Stream<T> Function(ApiRequest request) _getStream;

  ResourceAdapter(
    super.routePattern,
    super.bean,
    this._get,
    this._getStream,
  );

  @override
  Future<T> get(ApiRequest request) async => await _get(request);

  @override
  Stream<T> getStream(ApiRequest request) => _getStream(request);
}

class MutableResourceAdapter<T extends TransferObjectBase>
    extends ResourceAdapter<T> implements MutableResourceProvider<T> {
  final Future<void> Function(ApiRequest request, T value) _set;

  MutableResourceAdapter(
    super.routePattern,
    super.bean,
    super._get,
    this._set,
    super._getStream,
  );

  @override
  Future<void> set(ApiRequest request, T value) async => _set(request, value);
}
