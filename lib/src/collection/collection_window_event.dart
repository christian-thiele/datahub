import 'package:datahub/transfer_object.dart';

abstract class CollectionWindowEvent<Item extends TransferObjectBase<Id>, Id> {
  CollectionWindowEvent();
}

class CollectionInitEvent<Item extends TransferObjectBase<Id>, Id>
    extends CollectionWindowEvent<Item, Id> {
  final int collectionLength;
  final int windowOffset;
  final List<Item> data;

  CollectionInitEvent(
    this.collectionLength,
    this.windowOffset,
    this.data,
  );
}

class CollectionAlignEvent<Item extends TransferObjectBase<Id>, Id>
    extends CollectionWindowEvent<Item, Id> {
  final int collectionLength;
  final int windowOffset;

  CollectionAlignEvent(this.collectionLength, this.windowOffset);
}

class CollectionAddEvent<Item extends TransferObjectBase<Id>, Id>
    extends CollectionWindowEvent<Item, Id> {
  final int collectionLength;
  final int dataOffset;
  final List<Item> data;

  CollectionAddEvent(this.collectionLength, this.dataOffset, this.data);
}

class CollectionRemoveEvent<Item extends TransferObjectBase<Id>, Id>
    extends CollectionWindowEvent<Item, Id> {
  final int collectionLength;
  final Id id;

  CollectionRemoveEvent(this.collectionLength, this.id);
}

class CollectionUpdateEvent<Item extends TransferObjectBase<Id>, Id>
    extends CollectionWindowEvent<Item, Id> {
  final Item element;

  CollectionUpdateEvent(this.element);
}
