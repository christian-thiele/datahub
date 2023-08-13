import 'package:boost/boost.dart';
import 'package:datahub/collection.dart';
import 'package:datahub/transfer_object.dart';

class CollectionWindowState<Item extends TransferObjectBase<Id>, Id> {
  /// The total length of the collection.
  ///
  /// Not to be confused with the current [windowLength].
  /// Can be -1 to represent an endless collection.
  final int length;

  /// The current windows offset inside the collection.
  final int windowOffset;

  /// Window order bound.
  ///
  /// Order bound is used to find out if an item is inside or outside
  /// of a window. The lower bound is equal to the window offset only if items
  /// are sorted by their index.
  final int lowerBound;

  /// Window order bound.
  ///
  /// Order bound is used to find out if an item is inside or outside
  /// of a window. The lower bound is equal to the window offset only if items
  /// are sorted by their index.
  final int upperBound;

  /// The current windows size.
  int get windowLength => window.length;

  /// The current window of the collection.
  final List<OrderedData<Item>> window;

  Iterable<Item> get items => window.map((e) => e.data);

  //TODO min max is probably not necessary performance-wise because window should be sorted
  CollectionWindowState(
    this.length,
    this.windowOffset,
    this.window,
  )   : lowerBound = window.min((x) => x.order).order,
        upperBound = window.max((x) => x.order).order;

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
      return add(event.collectionLength, event.data);
    } else if (event is CollectionUpdateEvent<Item, Id>) {
      return update(event.element);
    } else if (event is CollectionRemoveEvent<Item, Id>) {
      return remove(event.collectionLength, event.id);
    }

    throw Exception('Invalid CollectionWindowEvent type.');
  }

  CollectionWindowState<Item, Id> add(
      int collectionLength, List<OrderedData<Item>> elements) {
    final updated = window.followedBy(elements).toList()
      ..sortBy((item) => item
          .order); //TODO performance, could be inserted without sorting everything
    return CollectionWindowState(collectionLength, windowOffset, updated);
  }

  CollectionWindowState<Item, Id> update(OrderedData<Item> element) {
    // maybe this is not necessary? but if element is in list multiple times,
    // it just might be
    ///TODO what if new order pushes it out of the window? maybe server should check for that and call remove instead
    final updated = window.toList()
      ..replaceWhere((e) => e.data.getId() == element.data.getId(), element)
      ..sortBy((item) => item.order);

    return CollectionWindowState(length, windowOffset, updated);
  }

  CollectionWindowState<Item, Id> remove(int collectionLength, Id id) {
    final updated = window.toList()..removeWhere((e) => e.data.getId() == id);
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
