import 'package:datahub/api.dart';
import 'package:datahub/src/hub/collection_size.dart';
import 'package:datahub/transfer_object.dart';

import 'collection_object.dart';

/// Base class for all Hub-Resources.
///
/// A hub resource is read-only by default. Other HubResource classes
/// like [MutableHubResource] are modifiable.
abstract class Resource<T extends TransferObjectBase> {
  final TransferBean<T> bean;
  final RoutePattern routePattern;

  Resource(this.routePattern, this.bean);

  /// Fetches the value of the resource once.
  Future<T> get();

  /// Subscribes to the resource and emits the value
  /// every time it updates.
  Stream<T> get stream;
}

abstract class MutableResource<T extends TransferObjectBase>
    extends Resource<T> {
  MutableResource(super.routePattern, super.bean);

  /// Pushes a new value to the resource.
  Future<void> set(T value);
}
