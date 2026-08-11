import 'dart:async';

import 'package:boost/boost.dart';

// TODO docs
// TODO replace "prints" with onError callback for implementing library to handle
class Pool<T> {
  final _items = <_PoolItem<T>>[];
  final _taken = <_PoolItem<T>>{};
  final _queue = <Completer<_PoolItem<T>>>[];

  final FutureOr<T> Function() _createItem;
  final FutureOr<bool> Function(T)? _checkIsLive;
  final Future<void> Function(T)? onRemoveItem;
  final void Function()? onChange;
  final _takeSemaphore = Semaphore();

  int targetSize;
  final Duration? maxLifetime;
  final Duration checkIsLiveTimeout;

  int get total => _items.length + _taken.length;

  int get available => _items.length;

  Pool(
    this.targetSize,
    this._createItem, {
    this.onRemoveItem,
    FutureOr<bool> Function(T)? checkIsLive,
    this.checkIsLiveTimeout = const Duration(seconds: 10),
    this.maxLifetime,
    this.onChange,
  }) : _checkIsLive = checkIsLive;

  Future<void> fill() async {
    for (var i = 0; i < targetSize; i++) {
      adopt(await _createItem());
    }
  }

  /// Returns a previously taken [item] back to the pool.
  ///
  /// Throws a [StateError] if the item is not currently taken from this
  /// pool. This guards against double-give and foreign items, either of
  /// which would result in the same item being handed out to multiple
  /// consumers at once. To add a new item to the pool, use [adopt] instead.
  void give(T item) {
    final poolItem = _taken.where((t) => t.item == item).firstOrNull;
    if (poolItem == null) {
      throw StateError(
        'Cannot give item: Item is not currently taken from this pool.',
      );
    }
    _release(poolItem);
  }

  /// Adds an externally created [item] to the pool.
  ///
  /// Throws a [StateError] if the item is already part of this pool.
  void adopt(T item) {
    if (_taken.any((t) => t.item == item) ||
        _items.any((t) => t.item == item)) {
      throw StateError('Cannot adopt item: Item is already part of the pool.');
    }
    _release(_PoolItem(item));
  }

  void _release(_PoolItem<T> poolItem) {
    if (_queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      if (!_taken.contains(poolItem)) {
        _taken.add(poolItem);
      }
      onChange?.call();
      next.complete(poolItem);
    } else {
      _taken.remove(poolItem);
      _items.add(poolItem);
      onChange?.call();
    }
  }

  T giveReserved(T item) {
    final poolItem =
        _taken.where((t) => t.item == item).firstOrNull ?? _PoolItem(item);
    if (!_taken.contains(poolItem)) {
      _taken.add(poolItem);
    }
    onChange?.call();
    return item;
  }

  /// Takes an item from the pool and provides it to the delegate.
  ///
  /// After delegate completes, the item is given back to the pool.
  ///
  /// If the pool is not filled to the target size yet, a new item
  /// is created using the [_createItem] delegate. If the pool has reached
  /// its target size but all elements are taken, the request for an item
  /// is queued and completed as soon as an element becomes available again.
  ///
  /// The [timeout] can be set to null, which means never. In the worst case,
  /// this method can take up to [timeout] + [checkIsLiveTimeout] to complete
  /// with an item or an error.
  Future<R> use<R>(
    FutureOr<R> Function(T) delegate, {
    Duration? timeout,
  }) async {
    final item = await take(timeout: timeout);
    try {
      return await delegate(item);
    } finally {
      give(item);
    }
  }

  /// Takes an item from the pool.
  ///
  /// After the item is no longer needed, it is required to give it back to the
  /// pool using [give] to make it available again. To avoid leaks, consider
  /// using [use] instead of [take] and [give].
  ///
  /// If the pool is not filled to the target size yet, a new item
  /// is created using the [_createItem] delegate. If the pool has reached
  /// its target size but all elements are taken, the request for an item
  /// is queued and completed as soon as an element becomes available again.
  ///
  /// The [timeout] can be set to null, which means never. In the worst case,
  /// this method can take up to [timeout] + [checkIsLiveTimeout] to complete
  /// with an item or an error.
  Future<T> take({Duration? timeout = const Duration(seconds: 30)}) async {
    return await _takeSemaphore.runLocked(() async {
      return await _takeInternal(timeout);
    });
  }

  Future<T> _takeInternal(Duration? timeout) async {
    if (available < 1 && total < targetSize) {
      return giveReserved(await _createItem());
    } else {
      try {
        final watch = Stopwatch()..start();
        final item = await _getNextOrEnqueue(timeout);

        if (await _isLive(item)) {
          watch.stop();
          return item.item;
        } else {
          _taken.removeWhere((i) => i.item == item.item);
          remove(item.item);
          watch.stop();
          if (timeout == null || watch.elapsed < timeout) {
            return await _takeInternal(
              timeout?.apply((t) => t - watch.elapsed),
            );
          } else {
            throw TimeoutException('Pool: take() timed out after $timeout.');
          }
        }
      } on TimeoutException catch (_) {
        // TimeoutException will show timeout after remaining duration,
        // not total duration, so replace the exception stack-upwards with
        // total timeout
        throw TimeoutException('Pool: take() timed out after $timeout.');
      }
    }
  }

  Future<_PoolItem<T>> _getNextOrEnqueue(Duration? timeout) async {
    if (_items.isNotEmpty) {
      final item = _items.removeAt(0);
      _taken.add(item);
      onChange?.call();
      return item;
    } else {
      final completer = Completer<_PoolItem<T>>();
      _queue.add(completer);
      onChange?.call();

      // The timeout decision and the queue removal must happen in a single
      // synchronous step: a waiter that is timed out is dequeued in the same
      // event-loop callback that fails it, so [give] can never complete a
      // waiter that already timed out (which would drop the item and leak it
      // as permanently taken).
      Timer? timeoutTimer;
      if (timeout != null) {
        timeoutTimer = Timer(timeout, () {
          if (_queue.remove(completer)) {
            onChange?.call();
            completer.completeError(
              TimeoutException('Pool: take() timed out after $timeout.'),
            );
          }
        });
      }

      try {
        return await completer.future;
      } finally {
        timeoutTimer?.cancel();
      }
    }
  }

  Future<bool> _isLive(_PoolItem<T> item) async {
    if (maxLifetime != null && item.age > maxLifetime!) {
      print('Pool: Item reached max lifetime.');
      return false;
    }

    if (_checkIsLive != null) {
      try {
        switch (_checkIsLive(item.item)) {
          case Future<bool> isLiveFuture:
            try {
              return await isLiveFuture.timeout(checkIsLiveTimeout);
            } on TimeoutException catch (_) {
              print(
                'Pool: Liveness check timed out after $checkIsLiveTimeout.',
              );
              return false;
            }
          case bool isLive:
            return isLive;
        }
      } catch (e) {
        print('Pool: Liveness check threw exception: $e');
        return false;
      }
    } else {
      return true;
    }
  }

  void remove(T item) {
    if (_taken.any((i) => i.item == item)) {
      throw Exception('Cannot remove item: Item is currently taken.');
    }

    _items.removeWhere((i) => i.item == item);
    onChange?.call();
    try {
      onRemoveItem?.call(item).catchError((error, stack) {
        print('onRemoveItem threw exception: $error');
      });
    } catch (error) {
      print('onRemoveItem threw exception: $error');
    }
  }
}

class _PoolItem<T> {
  final T item;
  final DateTime createTimestamp;

  _PoolItem(this.item) : createTimestamp = DateTime.now();

  Duration get age => DateTime.now().difference(createTimestamp);
}
