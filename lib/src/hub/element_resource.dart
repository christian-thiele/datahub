import 'package:datahub/datahub.dart';

abstract class ElementResource<T extends TransferObjectBase>
    extends Resource<T> {
  ElementResource(super.routePattern, super.bean);
}

abstract class MutableElementResource<T extends TransferObjectBase>
    extends ElementResource<T> {
  MutableElementResource(super.routePattern, super.bean);
}

abstract class ElementResourceClient<T extends TransferObjectBase>
    extends ElementResource<T> {
  ElementResourceClient(super.routePattern, super.bean);

  /// Fetches the value of the resource once.
  Future<T> get();

  /// Subscribes to the resource and emits the value
  /// every time it updates.
  Stream<T> getStream();
}

abstract class MutableElementResourceClient<T extends TransferObjectBase>
    extends ElementResourceClient<T> implements MutableElementResource<T> {
  MutableElementResourceClient(super.routePattern, super.bean);

  /// Pushes a new value to the resource.
  Future<void> set(T value);
}

abstract class ElementResourceProvider<T extends TransferObjectBase>
    extends ElementResource<T> implements ResourceProvider<T> {
  ElementResourceProvider(super.routePattern, super.bean);

  /// Fetches the value of the resource once.
  Future<T> get(ApiRequest request);

  /// Subscribes to the resource and emits the value
  /// every time it updates.
  Stream<T> getStream(ApiRequest request);
}

abstract class MutableElementResourceProvider<T extends TransferObjectBase>
    extends ElementResourceProvider<T> implements MutableElementResource<T> {
  MutableElementResourceProvider(super.routePattern, super.bean);

  /// Pushes a new value to the resource.
  Future<void> set(ApiRequest request, T value);
}
