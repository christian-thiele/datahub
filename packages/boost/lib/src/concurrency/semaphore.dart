import 'dart:async';

/// A semaphore prevents asynchronous code from being executed simultaneously.
///
/// Waiters are served strictly in FIFO order: releasing the lock hands it
/// over directly to the longest-waiting caller, so later callers cannot
/// barge in ahead of the queue and no waiter can be starved.
class Semaphore {
  final _waiters = <Completer<void>>[];
  bool _locked = false;
  Object? _scheduledKey;

  bool get isLocked => _locked;

  /// Function [job] is executed immediately if the semaphore is not locked,
  /// as soon as the last scheduled job finishes otherwise.
  Future<TResult> runLocked<TResult>(FutureOr<TResult> Function() job) async {
    try {
      await lock();
      return await job();
    } finally {
      release();
    }
  }

  /// Function [job] is executed only if the semaphore is not locked.
  Future<TResult?> throttle<TResult>(FutureOr<TResult> Function() job) async {
    if (isLocked) {
      return null;
    }

    try {
      await lock();
      return await job();
    } finally {
      release();
    }
  }

  /// Function [job] is only executed when no other job is scheduled within
  /// the [delay] period.
  Future<TResult?> debounce<TResult>(FutureOr<TResult> Function() job,
      {Duration delay = const Duration(milliseconds: 250)}) async {
    final key = _scheduledKey = Object();

    await Future.delayed(delay);

    return await runLocked(() async {
      if (_scheduledKey == key) {
        _scheduledKey = null;
        return await job();
      } else {
        return null;
      }
    });
  }

  /// Locks the semaphore. The Future completes as soon as all earlier
  /// holders of the lock released it. Waiters acquire the lock in FIFO
  /// order.
  ///
  /// Most of the time [runLocked], [debounce] or [throttle] should be preferred.
  Future<void> lock() {
    if (!_locked) {
      _locked = true;
      return Future.value();
    }

    final waiter = Completer<void>();
    _waiters.add(waiter);
    return waiter.future;
  }

  /// Releases the current lock on the semaphore.
  ///
  /// This is only necessary for special use cases in conjunction with [lock].
  /// Most of the time [runLocked], [debounce] or [throttle] should be preferred.
  void release() {
    if (_waiters.isNotEmpty) {
      // hand the lock over to the next waiter; the semaphore stays locked
      _waiters.removeAt(0).complete();
    } else {
      _locked = false;
    }
  }
}
