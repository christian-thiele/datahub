import 'dart:io';
import 'dart:math';

import 'package:boost/boost.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

void main() {
  test('runGuarded', _runGuardedTest);
  test('cancelOn', _cancelOnTest);
  test('Semaphore.runLocked', _semaphoreTest);
  test('Semaphore.debounce', _semaphoreDebounceTest);
  test('Semaphore.throttle', _semaphoreThrottleTest);
  test('Lazy', _lazyTest);
  test('Lazy.reinitialize', _lazyReinitializeTest, timeout: Timeout.none);
}

Future _runGuardedTest() async {
  //TODO extend test cases
  final r = Random();
  final asyncNoFailActions = Iterable.generate(
      10,
      (i) => (CancellationToken? token) =>
          Future.delayed(Duration(milliseconds: r.nextInt(500))));
  final asyncFailActions = Iterable.generate(
      10,
      (i) => (CancellationToken? token) async {
            await Future.delayed(Duration(milliseconds: r.nextInt(500)));
            // this is to avoid return type 'Never'
            if (r.nextInt(10) < 20) {
              throw Exception('Async Task $i failed successfully.');
            }
            return 'won\'t happen';
          });

  final syncNoFailActions = Iterable.generate(
      10,
      (i) => (CancellationToken? token) async {
            sleep(Duration(milliseconds: r.nextInt(200)));
            return 'result';
          });

  final syncFailActions = Iterable.generate(
      10,
      (i) => (CancellationToken? token) async {
            sleep(Duration(milliseconds: r.nextInt(200)));
            if (i > -5) {
              throw Exception('Sync Task $i failed successfully.');
            }
            return 'result';
          });

  final guardResults1 =
      await runGuarded(asyncNoFailActions.followedBy(asyncFailActions));
  expect(guardResults1.map((e) => e.success), isNot(everyElement(isTrue)));

  final guardResults2 = await runGuarded(syncNoFailActions);
  expect(guardResults2.map((e) => e.success), everyElement(isTrue));

  final guardResults3 = await runGuarded(syncFailActions);
  expect(guardResults3.map((e) => e.error), everyElement(isNotNull));
}

Future _cancelOnTest() async {
  final token = CancellationToken();
  final future = Future.delayed(Duration(seconds: 3)).cancelOn(token);
  unawaited(
      Future.delayed(Duration(seconds: 1)).then((value) => token.cancel()));
  expect(() async => await future, throwsA(isA<CanceledException>()));

  final token2 = CancellationToken();
  final future2 =
      Future.delayed(Duration(seconds: 1)).then((v) => 'x').cancelOn(token2);
  await Future.delayed(Duration(seconds: 2));
  token2.cancel();
  expect(await future2, equals('x'));
}

Future _semaphoreTest() async {
  final results = <int>[];
  Future _someTask(int i, bool fail) async {
    await Future.delayed(Duration(milliseconds: Random().nextInt(200)));
    results.add(i);
    if (fail) throw Exception();
  }

  final semaphore = Semaphore();
  unawaited(semaphore.runLocked(() async => _someTask(1, false)));
  await semaphore.runLocked(() async => _someTask(2, false));
  expect(() async => await semaphore.runLocked(() async => _someTask(3, true)),
      throwsException);
  await semaphore.runLocked(() async => _someTask(4, false));

  expect(results, orderedEquals([1, 2, 3, 4]));
}

Future<int> Function() _post(List<int> results, int x) => () async {
      await Future.delayed(Duration(milliseconds: 500));
      results.add(x);
      return x;
    };

Future _semaphoreThrottleTest() async {
  final results = <int>[];
  final returns = <int?>[];
  final ret = (int? value) => returns.add(value);
  final semaphore = Semaphore();

  unawaited(semaphore.throttle(_post(results, 1)).then(ret));
  unawaited(semaphore.throttle(_post(results, 2)).then(ret));
  await Future.delayed(Duration(milliseconds: 100));
  unawaited(semaphore.throttle(_post(results, 3)).then(ret));
  unawaited(semaphore.throttle(_post(results, 4)).then(ret));
  await Future.delayed(Duration(milliseconds: 410));
  unawaited(semaphore.throttle(_post(results, 5)).then(ret));
  unawaited(semaphore.throttle(_post(results, 6)).then(ret));
  await Future.delayed(Duration(milliseconds: 510));

  expect(results, orderedEquals([1, 5]));
  expect(returns, orderedEquals([null, null, null, 1, null, 5]));
}

Future _semaphoreDebounceTest() async {
  final results = <int>[];
  final returns = <int?>[];
  final ret = (int? value) => returns.add(value);
  final semaphore = Semaphore();

  await semaphore.debounce(_post(results, 1)).then(ret);
  await Future.delayed(Duration(seconds: 1));
  unawaited(semaphore.debounce(_post(results, 2)).then(ret));
  unawaited(semaphore.debounce(_post(results, 3)).then(ret));
  unawaited(semaphore.debounce(_post(results, 4)).then(ret));
  await semaphore.debounce(_post(results, 5)).then(ret);
  await Future.delayed(Duration(seconds: 1));
  unawaited(semaphore.debounce(_post(results, 6)).then(ret));
  await Future.delayed(Duration(milliseconds: 500));
  unawaited(semaphore.debounce(_post(results, 7)).then(ret));
  await Future.delayed(Duration(seconds: 1));
  unawaited(semaphore
      .debounce(_post(results, 8), delay: Duration(milliseconds: 500))
      .then(ret));
  await Future.delayed(Duration(milliseconds: 250));
  await semaphore
      .debounce(_post(results, 9), delay: Duration(milliseconds: 500))
      .then(ret);

  expect(results, orderedEquals([1, 5, 6, 7, 9]));
  expect(returns, orderedEquals([1, null, null, null, 5, 6, 7, null, 9]));
}

Future<void> _lazyTest() async {
  final lazy = Lazy(() async {
    await Future.delayed(const Duration(seconds: 1));
    return Random().nextInt(2048);
  });

  final results = await Future.wait(
      [lazy.get(), lazy.get(), lazy.get(), lazy.get(), lazy.get()]);

  expect(results.length, equals(5));
  expect(results, everyElement(equals(results.first)));

  lazy.invalidate();
  expect(lazy.isInitialized, isFalse);
  expect(await lazy.get(), isNot(equals(results.first)));

  final errorLazy = Lazy(() async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Nope');
  });

  expect(errorLazy.get, throwsA(isA<Exception>()));
  expect(errorLazy.get, throwsA(isA<Exception>()));
  expect(errorLazy.get, throwsA(isA<Exception>()));
  expect(errorLazy.get, throwsA(isA<Exception>()));
}

Future<void> _lazyReinitializeTest() async {
  final seq = [false, true, false].iterator;

  final lazy = Lazy<bool>(
    () {
      seq.moveNext();
      return seq.current;
    },
    reinitializeOnValue: (value) => !value,
  );

  expect([await lazy.get(), await lazy.get(), await lazy.get()],
      orderedEquals([false, true, true]));

  final errorSeq = [null, 1, 2].iterator;
  final errorLazy = Lazy<int>(
    () {
      errorSeq.moveNext();
      return errorSeq.current ?? (throw Exception('Supposed to fail.'));
    },
    reinitializeOnError: true,
  );

  expect(() async => await errorLazy.get(), throwsA(isA<Exception>()));
  expect(await errorLazy.get(), equals(1));
  expect(await errorLazy.get(), equals(1));
  expect(await errorLazy.get(), equals(1));
}
