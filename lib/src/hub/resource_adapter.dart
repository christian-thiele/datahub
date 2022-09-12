import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub/src/hub/resource.dart';

class ResourceAdapter<T extends TransferObjectBase> extends Resource<T> {
  final Future<T> Function(Map<String, String> params) _get;
  final Stream<T> Function(Map<String, String> params) _getStream;

  ResourceAdapter(
    super.routePattern,
    super.bean,
    this._get,
    this._getStream,
  );

  @override
  Future<T> get([Map<String, String> params = const {}]) async =>
      await _get(params);

  @override
  Stream<T> getStream([Map<String, String> params = const {}]) =>
      _getStream(params);
}

class MutableResourceAdapter<T extends TransferObjectBase>
    extends ResourceAdapter<T> implements MutableResource<T> {
  final Future<void> Function(T value, Map<String, String> params) _set;

  MutableResourceAdapter(
    super.routePattern,
    super.bean,
    super._get,
    this._set,
    super._getStream,
  );

  @override
  Future<void> set(T value, [Map<String, String> params = const {}]) async =>
      _set(value, params);
}
