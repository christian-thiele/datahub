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

  Future<T> get();
}

abstract class MutableResource<T extends TransferObjectBase> extends Resource<T> {
  MutableResource(super.routePattern, super.bean);

  Future<void> set(T value);
}