import 'package:datahub/collection.dart';
import 'package:datahub/transfer_object.dart';
import 'package:datahub/utils.dart';

import '../hub/transport/resource_transport_exception.dart';

class CollectionWindowState<Item extends TransferObjectBase<Id>, Id> {
  /// The total length of the collection.
  ///
  /// Not to be confused with the current [windowLength].
  /// Can be -1 to represent an endless collection.
  final int length;

  /// The current windows offset inside the collection.
  final int windowOffset;

  /// The current windows size.
  int get windowLength => window.length;

  /// The current window of the collection.
  final List<Item> window;

  CollectionWindowState(
    this.length,
    this.windowOffset,
    this.window,
  );

  bool isInWindow(int position) =>
      position >= windowOffset && position < (windowOffset + length);

  CollectionWindowState<Item, Id> mutate(
      CollectionWindowEvent<Item, Id> event) {
    if (event is CollectionInitEvent<Item, Id>) {
      return CollectionWindowState(
        event.collectionLength,
        event.windowOffset,
        event.data,
      );
    } else if (event is CollectionAlignEvent<Item, Id>) {
      return align(event.collectionLength, event.windowOffset);
    } else if (event is CollectionAddEvent<Item, Id>) {
      return add(event.collectionLength, event.dataOffset, event.data);
    } else if (event is CollectionUpdateEvent<Item, Id>) {
      return update(event.element);
    } else if (event is CollectionRemoveEvent<Item, Id>) {
      return remove(event.collectionLength, event.id);
    }

    throw Exception('Invalid CollectionWindowEvent type.');
  }

  CollectionWindowState<Item, Id> add(
      int collectionLength, int dataOffset, List<Item> elements) {
    if (isInWindow(dataOffset)) {
      final updated = window.toList()
        ..insertAll(dataOffset - windowOffset, elements);
      return CollectionWindowState(collectionLength, windowOffset, updated);
    } else {
      throw ApiError(
          'Position is outside of window. Window will be misaligned.');
    }
  }

  CollectionWindowState<Item, Id> update(Item element) {
    // maybe this is not necessary? but if element is in list multiple times,
    // it just might be
    final updated = window.toList()
      ..replaceWhere((e) => e.getId() == element.getId(), element);

    return CollectionWindowState(length, windowOffset, updated);
  }

  CollectionWindowState<Item, Id> remove(int collectionLength, Id id) {
    final updated = window.toList()..removeWhere((e) => e.getId() == id);
    return CollectionWindowState(collectionLength, windowOffset, updated);
  }

  CollectionWindowState<Item, Id> align(int length, int offset) =>
      CollectionWindowState(length, offset, window);
}

//TODO refactor
extension ReplaceWhereExtension<E> on List<E> {
  void replaceWhere(bool Function(E element) test, E replacement) {
    for (var i = 0; i < length; i++) {
      if (test(this[i])) {
        this[i] = replacement;
      }
    }
  }
}
