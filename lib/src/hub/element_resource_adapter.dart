import 'dart:async';

import 'package:datahub/api.dart';
import 'package:datahub/transfer_object.dart';

import 'element_resource.dart';

class ElementResourceAdapter<T extends TransferObjectBase>
    extends ElementResourceProvider<T> {
  final Future<T> Function(ApiRequest request) _get;
  final Stream<T> Function(ApiRequest request) _getStream;

  ElementResourceAdapter(
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

class MutableElementResourceAdapter<T extends TransferObjectBase>
    extends ElementResourceAdapter<T>
    implements MutableElementResourceProvider<T> {
  final Future<void> Function(ApiRequest request, T value) _set;

  MutableElementResourceAdapter(
    super.routePattern,
    super.bean,
    super._get,
    this._set,
    super._getStream,
  );

  @override
  Future<void> set(ApiRequest request, T value) async => _set(request, value);
}
