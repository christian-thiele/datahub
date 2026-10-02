import 'dart:async';
import 'dart:collection';

import 'package:datahub/abstract.dart';
import 'package:datahub/scaffold.dart';

/// Local in-memory, per-instance implementation of [LockProvider].
class MemoryLockService<T extends Object> implements Service {
  const MemoryLockService();

  @override
  ServiceInstance<MemoryLockService<T>> createInstance() =>
      _MemoryLockServiceInstance<T>();
}

class _MemoryLockServiceInstance<T extends Object>
    extends ServiceInstance<MemoryLockService<T>>
    implements LockProvider<T> {
  /// Locked keys and their waiters in FIFO order.
  final _locks = <T, Queue<Completer<void>>>{};
  bool _isDisposed = false;

  @override
  Future<LockHandle> acquireLock(
    T key, {
    Duration? timeout = Duration.zero,
  }) async {
    if (_isDisposed) {
      throw StateError('MemoryLockService is disposed.');
    }

    final waiters = _locks[key];
    if (waiters == null) {
      _locks[key] = Queue();
      return _MemoryLockHandle._(() => _release(key));
    }
    if (timeout != null && timeout <= Duration.zero) {
      throw ResourceLockedException();
    }

    final waiter = Completer<void>();
    waiters.add(waiter);
    try {
      await (timeout == null ? waiter.future : waiter.future.timeout(timeout));
    } on TimeoutException {
      // If the waiter is no longer queued, the lock was already handed over.
      if (waiters.remove(waiter)) {
        throw ResourceLockedException();
      }
    }
    return _MemoryLockHandle._(() => _release(key));
  }

  void _release(Object key) {
    final waiters = _locks[key];
    if (waiters == null || waiters.isEmpty) {
      _locks.remove(key);
    } else {
      waiters.removeFirst().complete();
    }
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    for (final waiters in _locks.values) {
      for (final waiter in waiters) {
        waiter.completeError(StateError('MemoryLockService is disposed.'));
      }
      waiters.clear();
    }
    await super.dispose();
  }
}

class _MemoryLockHandle implements LockHandle {
  final void Function() _release;
  bool _isReleased = false;

  _MemoryLockHandle._(this._release);

  @override
  bool get isValid => !_isReleased;

  @override
  Future<void> release() async {
    if (_isReleased) {
      return;
    }
    _isReleased = true;
    _release();
  }

  @override
  Future<void> get expired => Completer<void>().future;
}
