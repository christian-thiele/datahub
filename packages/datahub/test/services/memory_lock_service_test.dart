import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

void main() {
  declareTest('MemoryLockService resolves as LockProvider', [
    MemoryLockService(),
  ], () async {
    final provider = Find<LockProvider>().find();
    final result = await provider.runLocked('hello', () async => 'world');
    expect(result, equals('world'));
  });

  group('MemoryLockService', () {
    late ServiceInstance instance;
    late LockProvider provider;

    setUp(() {
      instance = const MemoryLockService().createInstance();
      provider = instance as LockProvider;
    });

    tearDown(() => instance.dispose());

    test('acquires and releases a free key', () async {
      final handle = await provider.acquireLock('key');
      expect(handle.isValid, isTrue);

      await handle.release();
      expect(handle.isValid, isFalse);
      expect(await provider.tryAcquireLock('key'), isNotNull);
    });

    test('rejects a held key without timeout', () async {
      await provider.acquireLock('key');

      await expectLater(
        provider.acquireLock('key'),
        throwsA(isA<ResourceLockedException>()),
      );
      expect(await provider.tryAcquireLock('key'), isNull);
    });

    test('locks keys independently', () async {
      await provider.acquireLock('a');
      expect(await provider.tryAcquireLock('b'), isNotNull);
    });

    test('compares keys by equality', () async {
      await provider.acquireLock(const _Key(1));
      expect(await provider.tryAcquireLock(const _Key(1)), isNull);
      expect(await provider.tryAcquireLock(const _Key(2)), isNotNull);
    });

    test('releasing twice does not release another holder', () async {
      final first = await provider.acquireLock('key');
      await first.release();
      final second = await provider.acquireLock('key');

      await first.release();

      expect(second.isValid, isTrue);
      expect(await provider.tryAcquireLock('key'), isNull);
    });

    test('waits for a lock released within the timeout', () async {
      final holder = await provider.acquireLock('key');
      final waiting = provider.acquireLock(
        'key',
        timeout: const Duration(seconds: 5),
      );

      await Future.delayed(const Duration(milliseconds: 10));
      await holder.release();

      final handle = await waiting;
      expect(handle.isValid, isTrue);
      expect(await provider.tryAcquireLock('key'), isNull);
    });

    test('rejects after the timeout elapsed', () async {
      await provider.acquireLock('key');

      await expectLater(
        provider.acquireLock('key', timeout: const Duration(milliseconds: 20)),
        throwsA(isA<ResourceLockedException>()),
      );
    });

    test('key is available after a rejected acquire', () async {
      final zeroTimeoutHolder = await provider.acquireLock('key');
      expect(await provider.tryAcquireLock('key'), isNull);
      await zeroTimeoutHolder.release();
      expect(await provider.tryAcquireLock('key'), isNotNull);

      final timeoutHolder = await provider.acquireLock('other');
      expect(
        await provider.tryAcquireLock(
          'other',
          timeout: const Duration(milliseconds: 20),
        ),
        isNull,
      );
      await timeoutHolder.release();
      expect(await provider.tryAcquireLock('other'), isNotNull);
    });

    test('waits without limit when timeout is null', () async {
      final holder = await provider.acquireLock('key');
      var acquired = false;
      final waiting = provider
          .acquireLock('key', timeout: null)
          .then((handle) => acquired = true);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(acquired, isFalse);

      await holder.release();
      await waiting;
      expect(acquired, isTrue);
    });

    test('hands the lock to waiters in FIFO order', () async {
      final order = <int>[];
      final holder = await provider.acquireLock('key');

      final waiters = [
        for (var i = 0; i < 3; i++)
          provider.runLocked(
            'key',
            () async => order.add(i),
            timeout: const Duration(seconds: 5),
          ),
      ];

      await holder.release();
      await Future.wait(waiters);
      expect(order, equals([0, 1, 2]));
    });

    test('skips timed out waiters when handing over', () async {
      final holder = await provider.acquireLock('key');
      final timedOut = provider.tryAcquireLock(
        'key',
        timeout: const Duration(milliseconds: 10),
      );
      final waiting = provider.acquireLock(
        'key',
        timeout: const Duration(seconds: 5),
      );

      expect(await timedOut, isNull);
      await holder.release();

      final handle = await waiting;
      expect(handle.isValid, isTrue);
    });

    test('runLocked returns the result and releases', () async {
      final result = await provider.runLocked('key', () async {
        expect(await provider.tryAcquireLock('key'), isNull);
        return 42;
      });

      expect(result, equals(42));
      expect(await provider.tryAcquireLock('key'), isNotNull);
    });

    test('runLocked passes exceptions through and releases', () async {
      await expectLater(
        provider.runLocked('key', () async => throw StateError('failed')),
        throwsA(isA<StateError>()),
      );
      expect(await provider.tryAcquireLock('key'), isNotNull);
    });

    test('runLocked throws when the key is held', () async {
      await provider.acquireLock('key');
      var called = false;

      await expectLater(
        provider.runLocked('key', () async => called = true),
        throwsA(isA<ResourceLockedException>()),
      );
      expect(called, isFalse);
    });

    test('locks never expire', () async {
      final handle = await provider.acquireLock('key');
      expect(handle.expired, doesNotComplete);
    });

    test('dispose fails waiters and rejects new acquires', () async {
      final holder = await provider.acquireLock('key');
      final waiting = expectLater(
        provider.acquireLock('key', timeout: null),
        throwsA(isA<StateError>()),
      );
      final waitingWithTimeout = expectLater(
        provider.acquireLock('key', timeout: const Duration(seconds: 5)),
        throwsA(isA<StateError>()),
      );

      await instance.dispose();

      await waiting;
      await waitingWithTimeout;
      await expectLater(
        provider.acquireLock('other'),
        throwsA(isA<StateError>()),
      );
      await holder.release();
    });
  });
}

class _Key {
  final int id;

  const _Key(this.id);

  @override
  bool operator ==(Object other) => other is _Key && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
