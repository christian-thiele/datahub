import 'dart:async';

import 'package:datahub/abstract.dart';
import 'package:datahub/telemetry.dart';

import '../abstract/redis_commands.dart';
import '../abstract/redis_script.dart';
import '../redis_telemetry.dart';

/// Deletes the lock only if it is still held by the given token and
/// notifies waiters through a Pub/Sub message on the channel named like the
/// lock key.
const releaseLockScript = RedisScript('''
if redis.call('get', KEYS[1]) == ARGV[1] then
  redis.call('del', KEYS[1])
  redis.call('publish', KEYS[1], 'released')
  return 1
end
return 0
''');

/// Extends the lease of the lock only if it is still held by the given
/// token.
const renewLockScript = RedisScript('''
if redis.call('get', KEYS[1]) == ARGV[1] then
  return redis.call('pexpire', KEYS[1], ARGV[2])
end
return 0
''');

/// [LockHandle] for a lock stored as Redis key with a lease (time to live).
///
/// The lease is renewed in the background every third of the lease
/// duration. The handle expires when a renewal finds the lock taken over
/// (after the lease ran out), or when no renewal succeeded for a whole lease
/// duration, for example because the server was unreachable.
class RedisLockHandle({
  /// The Redis key of the lock.
  required final String key,

  /// The key as requested by the caller, without prefix.
  required final String name,

  /// Random value identifying this holder.
  required final String token,
  required final Duration leaseDuration,

  /// Point in time (on [_clock]) until the lease is known to be valid.
  required var Duration _validUntil,

  /// Pooled commands that are not bound to a connection of the caller.
  required final RedisCommands _commands,

  /// Monotonic clock of the service.
  required final Stopwatch _clock,

  /// Zone for timers, independent of the zone of whoever acquired the lock.
  required final Zone _zone,
  required final RedisTelemetry _telemetry,
  required final void Function(RedisLockHandle handle) _onFinished,
}) implements LockHandle {
  /// Point in time (on [_clock]) the lock was acquired.
  final Duration _acquiredAt = _clock.elapsed;

  final _expired = Completer<void>();
  Timer? _renewTimer;
  Timer? _expiryTimer;
  var _released = false;
  var _renewing = false;

  this {
    _schedule(leaseDuration ~/ 3);
  }

  bool get _isFinished => _released || _expired.isCompleted;

  @override
  bool get isValid => !_isFinished && _clock.elapsed < _validUntil;

  @override
  Future<void> get expired => _expired.future;

  @override
  Future<void> release() async {
    if (_isFinished) {
      return;
    }
    _finish();
    _released = true;

    try {
      await _commands.eval(releaseLockScript, keys: [key], args: [token]);
    } catch (e, stack) {
      log.error(
        'Could not release Redis lock, it expires after its lease.',
        error: e,
        stack: stack,
        labels: {'lock.key': name},
      );
    }
  }

  /// Ends ownership because the service is disposed and deletes the lock if
  /// it was still valid.
  Future<void> abandon() async {
    if (_isFinished) {
      return;
    }
    final wasValid = isValid;
    _finish();
    _expired.complete();

    if (wasValid) {
      try {
        await _commands.eval(releaseLockScript, keys: [key], args: [token]);
      } catch (e, stack) {
        log.warn(
          'Could not release Redis lock on shutdown.',
          error: e,
          stack: stack,
          labels: {'lock.key': name},
        );
      }
    }
  }

  void _schedule(Duration renewIn) {
    _renewTimer?.cancel();
    _expiryTimer?.cancel();
    final remaining = _validUntil - _clock.elapsed;
    _zone.run(() {
      _expiryTimer = Timer(remaining, _expire);
      _renewTimer = Timer(renewIn, () => unawaited(_renew()));
    });
  }

  Future<void> _renew() async {
    if (_isFinished || _renewing) {
      return;
    }

    _renewing = true;
    final sentAt = _clock.elapsed;
    try {
      final reply = await _commands.eval(
        renewLockScript,
        keys: [key],
        args: [token, leaseDuration.inMilliseconds],
      );
      if (_isFinished) {
        return;
      }

      if (reply.asInt == 1) {
        _validUntil = sentAt + leaseDuration;
        _schedule(leaseDuration ~/ 3);
      } else {
        log.warn(
          'Redis lock was lost, its lease ran out before it was renewed.',
          labels: {'lock.key': name},
        );
        _expire();
      }
    } catch (e, stack) {
      if (_isFinished) {
        return;
      }
      _telemetry.lockRenewalFailed();
      log.warn(
        'Could not renew Redis lock, retrying.',
        error: e,
        stack: stack,
        labels: {'lock.key': name},
      );
      // retry until the lease runs out, the expiry timer stays in place
      _zone.run(() {
        _renewTimer = Timer(leaseDuration ~/ 10, () => unawaited(_renew()));
      });
    } finally {
      _renewing = false;
    }
  }

  void _expire() {
    if (_isFinished) {
      return;
    }
    _telemetry.lockLost();
    _finish();
    _expired.complete();
  }

  void _finish() {
    _telemetry.lockReleased(_clock.elapsed - _acquiredAt);
    _renewTimer?.cancel();
    _expiryTimer?.cancel();
    _onFinished(this);
  }
}
