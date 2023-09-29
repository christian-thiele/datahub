import 'package:datahub/api.dart';
import 'package:datahub/collection.dart';
import 'package:datahub/hub.dart';
import 'package:datahub/transfer_object.dart';

abstract class CollectionResource<Item extends TransferObjectBase<Id>, Id>
    extends Resource<Item> {
  CollectionResource(super.routePattern, super.bean);
}

abstract class CollectionResourceClient<Item extends TransferObjectBase<Id>, Id>
    extends CollectionResource<Item, Id>
    implements ReactiveCollection<Item, Id> {
  CollectionResourceClient(super.routePattern, super.bean);

  /// Subscribes to a stream of updated states regarding a section (window)
  /// of a collection.
  ///
  /// When given a previous collection, already loaded elements can be
  /// recycled to reduce traffic.
  @override
  Stream<CollectionWindowState<Item, Id>> getWindow(
    int offset,
    int length, {
    CollectionWindowState<Item, Id>? previous,
    Map<String, String> params = const {},
    Map<String, List<String>> query = const {},
  });
}

abstract class CollectionResourceProvider<Item extends TransferObjectBase<Id>,
    Id> extends CollectionResource<Item, Id> implements ResourceProvider<Item> {
  CollectionResourceProvider(super.routePattern, super.bean);

  /// Subscribes to a stream of update events regarding the requested window.
  Stream<CollectionWindowEvent<Item, Id>> getWindow(
    ApiRequest request,
    int offset,
    int length,
  );
}
