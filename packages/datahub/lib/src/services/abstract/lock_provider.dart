import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';

/// Ownership of an exclusive lock acquired through [LockProvider.acquireLock].
///
/// Call [release] once the protected work is done, or use
/// [LockProviderExtension.runLocked] to have it released automatically.
abstract interface class LockHandle {
  /// Whether the handle still holds ownership of the lock.
  ///
  /// This turns false when released by calling [release] or when the
  /// [LockProvider] implementation expires this lease.
  bool get isValid;

  /// Releases the lock this handle holds.
  ///
  /// Calling this twice on the same object is a no-op.
  /// When a lock is expired, this is also a no-op and does not release a lock
  /// that is held by another handle with the same key.
  ///
  /// An implementation **SHOULD NOT** throw an exception or error from here but
  /// log errors explicitly.
  Future<void> release();

  /// Completes when the lock expires.
  ///
  /// Does not complete when the lock is released using [release], and never
  /// completes for implementations without expiration.
  ///
  /// This **MUST NOT** complete with an error.
  Future<void> get expired;
}

/// A lock for a key could not be acquired.
class ResourceLockedException extends ApiRequestException {
  ResourceLockedException() : super(423, 'The resource is locked.');
}

/// Provides exclusive locks identified by keys of type [T].
///
/// At most one [LockHandle] can hold the lock for a given key at a time.
/// The scope of that exclusivity depends on the implementation.
///
/// Use [LockProviderExtension.runLocked] for the common acquire, run and
/// release pattern.
///
/// Locks are leases. Implementations decide whether and when an unreleased
/// lock expires, which lets a crashed holder's lock be recovered but means a
/// holder can lose its lock while still working.
///
/// To prevent unwanted expiration during long-running tasks, the implementation
/// **SHOULD** renew the lease automatically but can decide to do otherwise.
/// An implementation **MUST** complete the [LockHandle.expired] future
/// when a lock expires.
abstract interface class LockProvider<T extends Object> {
  /// Requests an exclusive lock for [key].
  ///
  /// Returns a [LockHandle] if the lock was successfully acquired or throws
  /// a [ResourceLockedException] otherwise.
  /// When a [timeout] is greater than zero, the implementation will wait
  /// for the lock to become available for that time before giving up.
  ///
  /// When [timeout] is explicitly set to null, the call waits for the
  /// implementations maximum timeout, which can be forever.
  Future<LockHandle> acquireLock(T key, {Duration? timeout = Duration.zero});
}

extension LockProviderExtension<T extends Object> on LockProvider<T> {
  /// Runs [delegate] only with acquired lock for [key] and releases afterwards.
  ///
  /// When [delegate] returns or throws, the lock is released immediately and
  /// the return value or exception passes through.
  ///
  /// Nested calls with the same [key] will see the lock as locked.
  Future<Result> runLocked<Result>(
    T key,
    Future<Result> Function(LockHandle handle) delegate, {
    Duration timeout = Duration.zero,
  }) async {
    final handle = await acquireLock(key, timeout: timeout);

    try {
      return await delegate(handle);
    } finally {
      try {
        await handle.release();
      } catch (e, stack) {
        log.error(
          'Could not release lock.',
          error: e,
          stack: stack,
          labels: {if (key case String() || num()) 'lock.key': key.toString()},
        );
      }
    }
  }

  /// Requests an exclusive lock for [key].
  ///
  /// Returns a [LockHandle] if the lock was successfully acquired or null
  /// otherwise.
  ///
  /// See [acquireLock].
  Future<LockHandle?> tryAcquireLock(
    T key, {
    Duration timeout = Duration.zero,
  }) async {
    try {
      return await acquireLock(key, timeout: timeout);
    } on ResourceLockedException {
      return null;
    }
  }
}
