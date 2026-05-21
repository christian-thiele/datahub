import 'dart:async';

/// A semaphore prevents asynchronous code from being executed simultaneously.
class Semaphore {
  Completer? completer;
  Object? _scheduledKey;

  bool get isLocked => !(completer?.isCompleted ?? true);

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

  /// Locks the semaphore. The Future completes as soon as the semaphore is
  /// released and can be locked again.
  ///
  /// Most of the time [runLocked], [debounce] or [throttle] should be preferred.
  Future lock() async {
    if (completer != null) {
      await completer!.future;
      await lock();
      return;
    }
    completer = Completer();
  }

  /// Releases the current lock on the semaphore.
  ///
  /// This is only necessary for special use cases in conjunction with [lock].
  /// Most of the time [runLocked], [debounce] or [throttle] should be preferred.
  void release() {
    final temp = completer;
    completer = null;
    temp?.complete();
  }
}
