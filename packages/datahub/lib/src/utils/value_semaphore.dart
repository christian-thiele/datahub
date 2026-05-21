import 'dart:async';

import 'package:boost/boost.dart';

class ValueSemaphore<T> {
  final _semaphore = Semaphore();
  final T _value;
  final void Function()? onRelease;

  ValueSemaphore(this._value, {this.onRelease});

  bool get isLocked => _semaphore.isLocked;

  Future<Lockable<T>> get() async {
    await _semaphore.lock();
    return Lockable<T>(_value, () {
      _semaphore.release();
      onRelease?.call();
    });
  }

  Future<Result> use<Result>(FutureOr<Result> Function(T) job) async {
    try {
      return await _semaphore.runLocked(() async {
        return await job(_value);
      });
    } finally {
      onRelease?.call();
    }
  }
}

class Lockable<T> {
  final T value;
  final void Function() release;

  Lockable(this.value, this.release);
}
