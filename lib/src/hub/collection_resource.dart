import 'package:datahub/datahub.dart';

abstract class CollectionResource<T extends TransferObjectBase<TId>, TId>
    extends Resource<T> {
  CollectionResource(super.routePattern, super.bean);
}

abstract class CollectionResourceClient<T extends TransferObjectBase<TId>, TId>
    extends CollectionResource<T, TId> {
  CollectionResourceClient(super.routePattern, super.bean);

  /// Subscribes to a stream of updated states regarding a section (window)
  /// of a collection.
  ///
  /// When given a previous collection, already loaded elements can be
  /// recycled to reduce traffic.
  Stream<CollectionState<T, TId>> getWindow(
    int offset,
    int length, {
    CollectionState<T, TId>? previous,
  });
}

abstract class CollectionResourceProvider<T extends TransferObjectBase<TId>,
    TId> extends CollectionResource<T, TId> implements ResourceProvider<T> {
  CollectionResourceProvider(super.routePattern, super.bean);

  /// Subscribes to a stream of update events regarding the requested window.
  Stream<CollectionEvent<T, TId>> getWindow(
    ApiRequest request,
    int offset,
    int length,
  );
}

//TODO refactor
class CollectionState<T extends TransferObjectBase<TId>, TId> {
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
  final List<T> window;

  CollectionState(
    this.length,
    this.windowOffset,
    this.window,
  );

  bool isInWindow(int position) =>
      position >= windowOffset && position < (windowOffset + length);

  CollectionState<T, TId> add(
      int collectionLength, int dataOffset, List<T> elements) {
    if (isInWindow(dataOffset)) {
      final updated = window.toList()
        ..insertAll(dataOffset - windowOffset, elements);
      return CollectionState(collectionLength, windowOffset, updated);
    } else {
      throw ApiError(
          'Position is outside of window. Window will be misaligned.');
    }
  }

  CollectionState<T, TId> update(T element) {
    // maybe this is not necessary? but if element is in list multiple times,
    // it just might be
    final updated = window.toList()
      ..replaceWhere((e) => e.getId() == element.getId(), element);

    return CollectionState(length, windowOffset, updated);
  }

  CollectionState<T, TId> remove(int collectionLength, TId id) {
    final updated = window.toList()..removeWhere((e) => e.getId() == id);
    return CollectionState(collectionLength, windowOffset, updated);
  }

  CollectionState<T, TId> align(int length, int offset) =>
      CollectionState(length, offset, window);
}

abstract class CollectionEvent<T extends TransferObjectBase<TId>, TId> {
  CollectionEvent();
}

class CollectionInitEvent<T extends TransferObjectBase<TId>, TId>
    extends CollectionEvent<T, TId> {
  final int collectionLength;
  final int windowOffset;
  final List<T> data;

  CollectionInitEvent(
    this.collectionLength,
    this.windowOffset,
    this.data,
  );
}

class CollectionAlignEvent<T extends TransferObjectBase<TId>, TId>
    extends CollectionEvent<T, TId> {
  final int collectionLength;
  final int windowOffset;

  CollectionAlignEvent(this.collectionLength, this.windowOffset);
}

class CollectionAddEvent<T extends TransferObjectBase<TId>, TId>
    extends CollectionEvent<T, TId> {
  final int collectionLength;
  final int dataOffset;
  final List<T> data;

  CollectionAddEvent(this.collectionLength, this.dataOffset, this.data);
}

class CollectionRemoveEvent<T extends TransferObjectBase<TId>, TId>
    extends CollectionEvent<T, TId> {
  final int collectionLength;
  final TId id;

  CollectionRemoveEvent(this.collectionLength, this.id);
}

class CollectionUpdateEvent<T extends TransferObjectBase<TId>, TId>
    extends CollectionEvent<T, TId> {
  final T element;

  CollectionUpdateEvent(this.element);
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
