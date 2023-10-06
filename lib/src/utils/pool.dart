import 'dart:async';

import 'package:boost/boost.dart';

class Pool<T> {
  final _items = <T>[];
  final _taken = <T>[];
  final _queue = <Completer<T>>[];

  int get total => _items.length + _taken.length;

  int get available => _items.length;

  Future<T> take({Duration? timeout}) async {
    if (_items.isNotEmpty) {
      final item = _items.removeAt(0);
      _taken.add(item);
      return item;
    } else {
      final completer = Completer<T>();
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

  void give(T item) {
    if (_queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      next.complete(item);
    } else {
      _items.add(item);
      _taken.remove(item);
    }
  }

  T giveReserved(T item) {
    _taken.add(item);
    return item;
  }

  void remove(T item) {
    _items.remove(item);
    _taken.remove(item);
  }
}
