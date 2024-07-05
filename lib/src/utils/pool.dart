import 'dart:async';

import 'package:boost/boost.dart';

//TODO docs
class Pool<T> {
  final _items = <_PoolItem<T>>[];
  final _taken = <_PoolItem<T>>[];
  final _queue = <Completer<_PoolItem<T>>>[];

  final FutureOr<T> Function() _createItem;
  final FutureOr<bool> Function(T)? _checkIsLive;
  final _takeSemaphore = Semaphore();

  int targetSize;
  final Duration? maxLifetime;

  int get total => _items.length + _taken.length;

  int get available => _items.length;

  Pool(
    this.targetSize,
    this._createItem, {
    FutureOr<bool> Function(T)? checkIsLive,
    this.maxLifetime,
  }) : _checkIsLive = checkIsLive;

  Future<void> fill() async {
    for (var i = 0; i < targetSize; i++) {
      give(await _createItem());
    }
  }

  void give(T item) {
    final poolItem =
        _taken.firstOrNullWhere((t) => t.item == item) ?? _PoolItem(item);
    if (_queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      if (!_taken.contains(poolItem)) {
        _taken.add(poolItem);
      }
      next.complete(poolItem);
    } else {
      _items.add(_PoolItem(item));
      _taken.remove(poolItem);
    }
  }

  T giveReserved(T item) {
    _taken.add(_PoolItem(item));
    return item;
  }

  Future<T> take({Duration? timeout}) async {
    return await _takeSemaphore.runLocked(() async {
      if (total < targetSize) {
        return giveReserved(await _createItem());
      } else {
        final item = await _takeInternal(timeout);

        if (await _isLive(item)) {
          return item.item;
        } else {
          remove(item.item);
          return await take(timeout: timeout);
        }
      }
    });
  }

  Future<_PoolItem<T>> _takeInternal(Duration? timeout) async {
    if (_items.isNotEmpty) {
      final item = _items.removeAt(0);
      _taken.add(item);
      return item;
    } else {
      final completer = Completer<_PoolItem<T>>();
      _queue.add(completer);

      if (timeout == null) {
        return await completer.future;
      } else {
        try {
          return await completer.future.timeout(timeout);
        } on TimeoutException catch (_) {
          _queue.remove(completer);
          rethrow;
        }
      }
    }
  }

  Future<bool> _isLive(_PoolItem<T> item) async {
    if (maxLifetime != null && item.age > maxLifetime!) {
      return false;
    }

    try {
      return await _checkIsLive!(item.item);
    } catch (_) {
      remove(item.item);
      rethrow;
    }
  }

  void remove(T item) {
    _items.removeWhere((i) => i.item == item);
    _taken.removeWhere((i) => i.item == item);
  }
}

class _PoolItem<T> {
  final T item;
  final DateTime createTimestamp;

  _PoolItem(this.item) : createTimestamp = DateTime.now();

  Duration get age => DateTime.now().difference(createTimestamp);
}
