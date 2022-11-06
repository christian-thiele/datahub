import 'dart:async';

import 'package:datahub/api.dart';
import 'package:datahub/transfer_object.dart';

/// Base class for all Hub-Resources.
///
/// A hub resource is read-only by default. Other HubResource classes
/// like [MutableHubResource] are modifiable.
abstract class Resource<T extends TransferObjectBase> {
  final TransferBean<T> bean;
  final RoutePattern routePattern;

  Resource(this.routePattern, this.bean);
}

abstract class MutableResource<T extends TransferObjectBase>
    extends Resource<T> {
  MutableResource(super.routePattern, super.bean);
}

abstract class ResourceClient<T extends TransferObjectBase>
    extends Resource<T> {
  ResourceClient(super.routePattern, super.bean);

  /// Fetches the value of the resource once.
  Future<T> get();

  /// Subscribes to the resource and emits the value
  /// every time it updates.
  Stream<T> getStream();
}

abstract class MutableResourceClient<T extends TransferObjectBase>
    extends ResourceClient<T> implements MutableResource<T> {
  MutableResourceClient(super.routePattern, super.bean);

  /// Pushes a new value to the resource.
  Future<void> set(T value);
}

abstract class ResourceProvider<T extends TransferObjectBase>
    extends Resource<T> {
  ResourceProvider(super.routePattern, super.bean);

  /// Fetches the value of the resource once.
  Future<T> get(ApiRequest request);

  /// Subscribes to the resource and emits the value
  /// every time it updates.
  Stream<T> getStream(ApiRequest request);
}

abstract class MutableResourceProvider<T extends TransferObjectBase>
    extends ResourceProvider<T> implements MutableResource<T> {
  MutableResourceProvider(super.routePattern, super.bean);

  /// Pushes a new value to the resource.
  Future<void> set(ApiRequest request, T value);
}
