import 'dart:async';

import 'package:datahub/api.dart';
import 'package:datahub/transfer_object.dart';

/// Base class for all Hub-Resources.
abstract class Resource<T extends TransferObjectBase> {
  final TransferBean<T> bean;
  final RoutePattern routePattern;

  Resource(this.routePattern, this.bean);
}

abstract class ResourceProvider<T> {}
