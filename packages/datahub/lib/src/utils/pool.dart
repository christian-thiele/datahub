import 'dart:async';

import 'package:datahub/api.dart';

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

  /// Number of items currently being created for reserved take() calls.
  ///
  /// Counted into [total] so that concurrent [take] calls cannot decide to
  /// create more items than [targetSize] allows while creations are still
  /// in flight.
  int _creating = 0;

  int targetSize;
  final Duration? maxLifetime;
  final Duration checkIsLiveTimeout;

  /// Maximum number of [take] requests waiting for an item at the same time.
  ///
  /// When the pool is exhausted and the queue has reached this length,
  /// further [take] calls fail immediately with a [PoolQueueLimitException]
  /// instead of queueing up. This provides backpressure under overload
  /// instead of unbounded memory growth. Null means unlimited.
  final int? maxQueueLength;

  bool _disposed = false;

  int get total => _items.length + _taken.length + _creating;

  int get available => _items.length;

  /// Whether [dispose] has been called.
  bool get isDisposed => _disposed;

  Pool(
    this.targetSize,
    this._createItem, {
    this.onRemoveItem,
    FutureOr<bool> Function(T)? checkIsLive,
    this.checkIsLiveTimeout = const Duration(seconds: 10),
    this.maxLifetime,
    this.maxQueueLength,
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

    // items returned after dispose are finalized instead of pooled
    if (_disposed) {
      _taken.remove(poolItem);
      onChange?.call();
      _finalizeItem(poolItem.item);
      return;
    }

    _release(poolItem);
  }

  /// Adds an externally created [item] to the pool.
  ///
  /// Throws a [StateError] if the item is already part of this pool.
  void adopt(T item) {
    if (_disposed) {
      throw StateError('Pool has been disposed.');
    }
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

  /// Takes an item from the pool and provides it to the delegate.
  ///
  /// After delegate completes, the item is given back to the pool.
  ///
  /// If the pool is not filled to the target size yet, a new item
  /// is created using the [_createItem] delegate. If the pool has reached
  /// its target size but all elements are taken, the request for an item
  /// is queued and completed as soon as an element becomes available again.
  ///
  /// The [timeout] limits the time spent waiting for an item to become
  /// available, including time spent waiting in the queue. It can be set to
  /// null, which means waiting indefinitely. In the worst case, this method
  /// can take up to [timeout] + [checkIsLiveTimeout] + the duration of a
  /// single item creation to complete with an item or an error.
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
  /// If an idle item is available, it is returned after passing the liveness
  /// check. If not, and the pool has not reached its target size yet, a new
  /// item is created using the [_createItem] delegate. Otherwise the request
  /// is queued (FIFO) and completed as soon as an item becomes available
  /// again.
  ///
  /// The [timeout] limits the time spent waiting for an item to become
  /// available, including time spent waiting in the queue. It can be set to
  /// null, which means waiting indefinitely. In the worst case, this method
  /// can take up to [timeout] + [checkIsLiveTimeout] + the duration of a
  /// single item creation to complete with an item or an error.
  ///
  /// Throws a [PoolQueueLimitException] immediately if the pool is exhausted
  /// and [maxQueueLength] requests are already waiting for an item.
  Future<T> take({Duration? timeout = const Duration(seconds: 30)}) async {
    if (_disposed) {
      throw StateError('Pool has been disposed.');
    }

    final watch = Stopwatch()..start();

    while (true) {
      // All bookkeeping between checking the pool state and reserving an
      // item / creation slot / queue position is synchronous, so concurrent
      // take() calls cannot interleave within a single decision.
      if (_items.isNotEmpty) {
        final item = _items.removeAt(0);
        _taken.add(item);
        onChange?.call();

        if (await _isLive(item)) {
          return item.item;
        }

        _taken.remove(item);
        remove(item.item);
      } else if (total < targetSize) {
        _creating++;
        onChange?.call();
        try {
          final poolItem = _PoolItem(await _createItem());
          _taken.add(poolItem);
          return poolItem.item;
        } catch (_) {
          // Creation failed, so the reserved capacity opens up again. Wake
          // the next queued waiter (if any) to let it retry and create a
          // replacement instead of waiting for an item that may never come.
          if (_queue.isNotEmpty) {
            _queue.removeAt(0).completeError(const _RetryTake());
          }
          rethrow;
        } finally {
          _creating--;
          onChange?.call();
        }
      } else {
        final _PoolItem<T> item;
        try {
          item = await _enqueue(_remainingTimeout(timeout, watch));
        } on TimeoutException catch (_) {
          // The queue timeout reports the remaining duration, not the total
          // duration, so replace the exception with the total timeout.
          throw TimeoutException('Pool: take() timed out after $timeout.');
        } on _RetryTake catch (_) {
          continue;
        }

        if (await _isLive(item)) {
          return item.item;
        }

        _taken.remove(item);
        remove(item.item);
      }

      // only reached after receiving a dead item: retry within timeout
      if (timeout != null && watch.elapsed >= timeout) {
        throw TimeoutException('Pool: take() timed out after $timeout.');
      }
    }
  }

  Duration? _remainingTimeout(Duration? timeout, Stopwatch watch) {
    if (timeout == null) {
      return null;
    }
    final remaining = timeout - watch.elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<_PoolItem<T>> _enqueue(Duration? timeout) async {
    if (maxQueueLength != null && _queue.length >= maxQueueLength!) {
      throw PoolQueueLimitException(maxQueueLength!);
    }

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
    _finalizeItem(item);
  }

  void _finalizeItem(T item) {
    try {
      onRemoveItem?.call(item).catchError((error, stack) {
        print('onRemoveItem threw exception: $error');
      });
    } catch (error) {
      print('onRemoveItem threw exception: $error');
    }
  }

  /// Shuts down the pool.
  ///
  /// All queued [take] requests are completed with a [StateError], all idle
  /// items are removed via [onRemoveItem] and further calls to [take],
  /// [adopt] and [fill] throw a [StateError].
  ///
  /// Items that are taken at the time of disposal are not touched; they are
  /// finalized via [onRemoveItem] as soon as they are given back with [give].
  ///
  /// Calling dispose more than once has no effect.
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;

    final waiters = List.of(_queue);
    _queue.clear();
    for (final waiter in waiters) {
      waiter.completeError(StateError('Pool has been disposed.'));
    }

    final idle = List.of(_items);
    _items.clear();
    onChange?.call();
    for (final poolItem in idle) {
      try {
        await onRemoveItem?.call(poolItem.item);
      } catch (error) {
        print('onRemoveItem threw exception: $error');
      }
    }
  }
}

/// Thrown by [Pool.take] when the pool is exhausted and the queue of waiting
/// requests has reached [Pool.maxQueueLength].
///
/// This is a backpressure signal: the pool is overloaded and the caller
/// should fail fast instead of adding more waiters.
class PoolQueueLimitException extends ApiRequestException {
  final int queueLimit;

  PoolQueueLimitException(this.queueLimit) : super(503, null);

  @override
  String toString() =>
      'PoolQueueLimitException: Pool queue limit of $queueLimit reached.';
}

/// Internal signal for queued waiters in [Pool.take]: capacity opened up
/// (e.g. a concurrent item creation failed), retry taking instead of
/// waiting for an item to be given back.
class _RetryTake implements Exception {
  const _RetryTake();
}

class _PoolItem<T> {
  final T item;
  final DateTime createTimestamp;

  _PoolItem(this.item) : createTimestamp = DateTime.now();

  Duration get age => DateTime.now().difference(createTimestamp);
}
