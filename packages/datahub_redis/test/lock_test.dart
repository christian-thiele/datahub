import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

import 'utils/redis_test_utils.dart';

LockProvider<String> _locks() => Find<LockProvider<String>>().find();

void main() {
  redisGroup('Redis locks', (env) {
    env.test('acquires and releases a free key', (redis) async {
      final locks = _locks();
      final handle = await locks.acquireLock('job');
      expect(handle.isValid, isTrue);
      expect(await redis.exists('datahub:lock:job'), isTrue);

      final ttl = await redis.ttl('datahub:lock:job');
      expect(ttl!.inSeconds, inInclusiveRange(28, 30));

      await handle.release();
      expect(handle.isValid, isFalse);
      expect(await redis.exists('datahub:lock:job'), isFalse);
      expect(await locks.tryAcquireLock('job'), isNotNull);
    });

    env.test('uses the configured key prefix', (redis) async {
      await _locks().acquireLock('job');
      expect(await redis.exists('app:locks:job'), isTrue);
    }, config: {'lockPrefix': 'app:locks:'});

    env.test('rejects a held key without timeout', (redis) async {
      final locks = _locks();
      await locks.acquireLock('job');

      await expectLater(
        locks.acquireLock('job'),
        throwsA(isA<ResourceLockedException>()),
      );
      expect(await locks.tryAcquireLock('job'), isNull);
      expect(await locks.tryAcquireLock('other'), isNotNull);
    });

    env.test('runLocked returns the result and releases', (redis) async {
      final locks = _locks();
      final result = await locks.runLocked('job', () async {
        expect(await locks.tryAcquireLock('job'), isNull);
        return 42;
      });

      expect(result, equals(42));
      expect(await redis.exists('datahub:lock:job'), isFalse);
    });

    env.test('runLocked releases when the delegate throws', (redis) async {
      final locks = _locks();
      await expectLater(
        locks.runLocked('job', () async => throw StateError('failed')),
        throwsStateError,
      );
      expect(await locks.tryAcquireLock('job'), isNotNull);
    });

    env.test('releasing twice does not release another holder', (redis) async {
      final locks = _locks();
      final first = await locks.acquireLock('job');
      await first.release();
      final second = await locks.acquireLock('job');

      await first.release();

      expect(second.isValid, isTrue);
      expect(await locks.tryAcquireLock('job'), isNull);
    });

    env.test('a waiter is woken immediately on release', (redis) async {
      final locks = _locks();
      final holder = await locks.acquireLock('job');
      final watch = Stopwatch();
      final waiting = locks
          .acquireLock('job', timeout: const Duration(seconds: 20))
          .then((handle) {
            watch.stop();
            return handle;
          });

      // let the waiter subscribe before releasing
      await Future<void>.delayed(const Duration(milliseconds: 300));
      watch.start();
      await holder.release();

      final handle = await waiting;
      expect(handle.isValid, isTrue);
      // the retry interval is 10s, only the release notification is fast
      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
    }, config: {'lockRetryInterval': 10000});

    env.test('a waiter acquires an expired lock by polling', (redis) async {
      // held by a crashed process that never releases
      await redis.set(
        'datahub:lock:job',
        'foreign-token',
        ttl: const Duration(milliseconds: 300),
      );

      final handle = await _locks().acquireLock(
        'job',
        timeout: const Duration(seconds: 5),
      );
      expect(handle.isValid, isTrue);
      expect(await redis.get('datahub:lock:job'), isNot('foreign-token'));
    }, config: {'lockRetryInterval': 100});

    env.test('rejects after the timeout elapsed', (redis) async {
      final locks = _locks();
      await locks.acquireLock('job');
      final watch = Stopwatch()..start();

      await expectLater(
        locks.acquireLock('job', timeout: const Duration(milliseconds: 300)),
        throwsA(isA<ResourceLockedException>()),
      );
      expect(
        watch.elapsed,
        greaterThanOrEqualTo(const Duration(milliseconds: 300)),
      );
      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
    });

    env.test('waits without limit when timeout is null', (redis) async {
      final locks = _locks();
      final holder = await locks.acquireLock('job');
      var acquired = false;
      final waiting = locks
          .acquireLock('job', timeout: null)
          .then((handle) => acquired = true);

      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(acquired, isFalse);

      await holder.release();
      await waiting.timeout(const Duration(seconds: 5));
      expect(acquired, isTrue);
    });

    env.test('renews the lease while held', (redis) async {
      final handle = await _locks().acquireLock('job');

      await Future<void>.delayed(const Duration(milliseconds: 1200));

      expect(handle.isValid, isTrue);
      expect(await redis.exists('datahub:lock:job'), isTrue);
      expect(await _locks().tryAcquireLock('job'), isNull);
      await handle.release();
    }, config: {'lockLeaseDuration': 300});

    env.test('expires when the lock was taken over', (redis) async {
      final handle = await _locks().acquireLock('job');
      var expired = false;
      unawaited(handle.expired.then((_) => expired = true));

      // the lease ran out and another holder took the lock
      await redis.set('datahub:lock:job', 'foreign-token');
      await handle.expired.timeout(const Duration(seconds: 2));

      expect(expired, isTrue);
      expect(handle.isValid, isFalse);

      // releasing an expired handle does not touch the other holder
      await handle.release();
      expect(await redis.get('datahub:lock:job'), equals('foreign-token'));
    }, config: {'lockLeaseDuration': 300});

    env.test('expired does not complete for released locks', (redis) async {
      final handle = await _locks().acquireLock('job');
      await handle.release();
      expect(handle.expired, doesNotComplete);
    });

    env.test('locks are exclusive across service instances', (redis) async {
      final other = await env.startHost();
      try {
        final providers = [_locks(), other.locks];
        await redis.set('counter', '0');

        // a non-atomic read-modify-write that loses updates without locking
        Future<void> increment(LockProvider<String> locks) =>
            locks.runLocked('counter', () async {
              final value = int.parse((await redis.get('counter'))!);
              await Future<void>.delayed(const Duration(milliseconds: 2));
              await redis.set('counter', '${value + 1}');
            }, timeout: const Duration(seconds: 20));

        await Future.wait([
          for (var i = 0; i < 40; i++) increment(providers[i % 2]),
        ]);

        expect(await redis.get('counter'), equals('40'));
      } finally {
        await other.stop();
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    env.test('locks work inside useConnection', (redis) async {
      await redis.useConnection((connection) async {
        await connection.watch(['watched']);
        final handle = await _locks().acquireLock('job');
        await handle.release();
        // lock commands did not run on the bound connection
        expect(await connection.transaction((tx) => tx.set('a', '1')), isTrue);
      });
    });

    test('dispose fails waiters and releases held locks', () async {
      final host = await env.startHost();
      final holder = await host.locks.acquireLock('job');
      final waiting = expectLater(
        host.locks.acquireLock('job', timeout: null),
        throwsStateError,
      );
      var expired = false;
      unawaited(holder.expired.then((_) => expired = true));

      await host.stop();
      await waiting;

      expect(expired, isTrue);
      expect(holder.isValid, isFalse);
      final check = await env.startHost();
      try {
        expect(await check.redis.exists('datahub:lock:job'), isFalse);
      } finally {
        await check.stop();
      }
    });
  });
}
