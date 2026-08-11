import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

Matcher poolState(int target, int total, int available) => isA<Pool>()
    .having((p) => p.targetSize, 'targetSize', equals(target))
    .having((p) => p.total, 'total', equals(total))
    .having((p) => p.available, 'available', equals(available));

void main() {
  group('Pool', () {
    test('Should have as many items available as target after fill', () async {
      final pool = Pool(5, createItem);
      expect(pool, poolState(5, 0, 0));
      await pool.fill();
      expect(pool, poolState(5, 5, 5));
    });

    test('Should make taken items unavailable', () async {
      final pool = Pool(2, createItem);
      await pool.fill();
      await pool.take();
      expect(pool, poolState(2, 2, 1));
      await pool.take();
      expect(pool, poolState(2, 2, 0));
    });

    test('Should make given items available', () async {
      final pool = Pool(2, createItem);
      await pool.fill();
      pool.adopt(Item());
      expect(pool, poolState(2, 3, 3));
      await pool.take();
      await pool.take();
      final item = await pool.take();
      expect(pool, poolState(2, 3, 0));
      pool.give(item);
      expect(pool, poolState(2, 3, 1));
      final item2 = await pool.take();
      expect(item2.id, equals(item.id));
    });

    test('Should not create new items when size >= targetSize', () async {
      final pool = Pool(3, createItem);
      await pool.fill();
      for (var i = 0; i < 3; i++) {
        await pool.take();
      }

      expect(
        () async => await pool.take(timeout: Duration(seconds: 3)),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('Should create new items when size < targetSize', () async {
      final pool = Pool(3, createItem);
      expect(pool, poolState(3, 0, 0));
      final item1 = await pool.take();
      expect(pool, poolState(3, 1, 0));
      final item2 = await pool.take();
      expect(pool, poolState(3, 2, 0));
      final item3 = await pool.take();
      expect(pool, poolState(3, 3, 0));
      pool.give(item1);
      expect(pool, poolState(3, 3, 1));
      pool.give(item2);
      expect(pool, poolState(3, 3, 2));
      pool.give(item3);
      expect(pool, poolState(3, 3, 3));
    });

    test('Should remove "not live" items from pool', () async {
      final liveItem = Item();
      final deadItem = Item();
      final pool = Pool(
        2,
        createItem,
        checkIsLive: checkLiveWhereId(liveItem.id),
        checkIsLiveTimeout: Duration(milliseconds: 500),
      );
      pool.adopt(liveItem);
      pool.adopt(deadItem);

      final item1 = await pool.take();
      expect(pool, poolState(2, 2, 1));

      final item2 = await pool.take();
      expect(pool, poolState(2, 2, 0));

      expect(item1.id, equals(liveItem.id));
      expect(item1.id, isNot(equals(deadItem.id)));
      expect(item2.id, isNot(equals(liveItem.id)));
      expect(item2.id, isNot(equals(deadItem.id)));
    });

    test('Should remove items older than maxLifetime from pool', () async {
      final liveItem = Item();
      final deadItem = Item();
      final pool = Pool(
        2,
        createItem,
        checkIsLive: checkLiveAlwaysOn,
        maxLifetime: Duration(milliseconds: 400),
      );
      pool.adopt(deadItem);
      await Future.delayed(const Duration(milliseconds: 500));
      pool.adopt(liveItem);

      expect(pool, poolState(2, 2, 2));
      final item1 = await pool.take();
      expect(pool, poolState(2, 1, 0));

      final item2 = await pool.take();
      expect(pool, poolState(2, 2, 0));

      expect(item1.id, isNot(equals(deadItem.id)));
      expect(item2.id, isNot(equals(deadItem.id)));
    });

    test(
      'Should consider "not live" when live check does not finish within timeout',
      () async {
        final pool = Pool(
          1,
          createItem,
          checkIsLive: checkLiveNever,
          checkIsLiveTimeout: Duration(seconds: 3),
        );
        // creates new item, doesn't check
        final item1 = await pool.take();
        expect(pool, poolState(1, 1, 0));

        // returning "dead" item
        pool.give(item1);
        expect(pool, poolState(1, 1, 1));

        final item2 = await pool.take();
        expect(item1.id, isNot(equals(item2.id)));
        expect(pool, poolState(1, 1, 0));
      },
    );

    test(
      'Should queue request when at capacity and complete when item comes available in order',
      () async {
        final pool = Pool(2, createItem);
        final item1 = await pool.take();
        final item2 = await pool.take();

        expect(pool, poolState(2, 2, 0));
        final comp1 = Completer<Item>();
        final comp2 = Completer<Item>();

        pool.take().then(comp2.complete);
        pool.take().then(comp1.complete);
        await Future.delayed(const Duration(milliseconds: 100));

        pool.give(item2);
        pool.give(item1);

        expect(
          comp1.future,
          completion(isA<Item>().having((i) => i.id, 'id', equals(item1.id))),
        );
        expect(
          comp2.future,
          completion(isA<Item>().having((i) => i.id, 'id', equals(item2.id))),
        );
      },
    );

    test('Should call onRemoveItem when removing an item from pool', () async {
      final item = Item();
      final completer = Completer<Item>();
      final pool = Pool(
        1,
        createItem,
        checkIsLive: checkLiveNever,
        onRemoveItem: (i) async => completer.complete(i),
      );
      pool.adopt(item);
      await pool.take();
      expect(
        completer.future,
        completion(isA<Item>().having((i) => i.id, 'id', equals(item.id))),
      );
    });

    test(
      'Should not leak item when given back after queued take timed out',
      () async {
        final pool = Pool(1, createItem);
        final item = await pool.take();

        await expectLater(
          () => pool.take(timeout: Duration(milliseconds: 100)),
          throwsA(isA<TimeoutException>()),
        );

        // the timed out waiter must be gone from the queue, so giving the
        // item back makes it available again instead of handing it to a
        // waiter that no longer listens
        pool.give(item);
        expect(pool, poolState(1, 1, 1));

        final item2 = await pool.take(timeout: Duration(milliseconds: 100));
        expect(item2.id, equals(item.id));
      },
    );

    test('Should either serve waiter or retain item when give() coincides '
        'with take() timeout', () async {
      final pool = Pool(1, createItem);
      final item = await pool.take();

      // schedule give() to race with the waiter's timeout
      Timer(Duration(milliseconds: 100), () => pool.give(item));

      Item? received;
      try {
        received = await pool.take(timeout: Duration(milliseconds: 100));
      } on TimeoutException catch (_) {
        // acceptable outcome of the race
      }

      if (received != null) {
        pool.give(received);
      } else {
        // wait for the scheduled give() to have fired
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // whichever side won, the item must not be stranded in "taken"
      expect(pool, poolState(1, 1, 1));
    });

    test('Should apply timeouts to concurrent take() calls independently, '
        'not serially', () async {
      final pool = Pool(1, createItem);
      final item = await pool.take();

      final watch = Stopwatch()..start();
      final results = await Future.wait([
        for (var i = 0; i < 3; i++)
          pool
              .take(timeout: Duration(milliseconds: 200))
              .then((_) => 'item', onError: (_) => 'timeout'),
      ]);
      watch.stop();

      expect(results, everyElement(equals('timeout')));
      // waiters time out concurrently (~200ms), not one after another (600ms)
      expect(watch.elapsed, lessThan(const Duration(milliseconds: 500)));
      pool.give(item);
    });

    test(
      'Should not block timed take() behind take() without timeout',
      () async {
        final pool = Pool(1, createItem);
        final item = await pool.take();

        // waits indefinitely for the item to come back
        final infiniteTake = pool.take(timeout: null);

        // must time out on its own instead of waiting behind infiniteTake
        await expectLater(
          () => pool.take(timeout: Duration(milliseconds: 100)),
          throwsA(isA<TimeoutException>()),
        );

        pool.give(item);
        final served = await infiniteTake;
        expect(served.id, equals(item.id));
      },
    );

    test('Should not create more than targetSize items under concurrent '
        'take() calls', () async {
      final pool = Pool(2, createItem);

      final items = await Future.wait([
        for (var i = 0; i < 5; i++)
          () async {
            final item = await pool.take(timeout: Duration(seconds: 5));
            expect(pool.total, lessThanOrEqualTo(2));
            await Future.delayed(const Duration(milliseconds: 20));
            pool.give(item);
            return item;
          }(),
      ]);

      expect(pool, poolState(2, 2, 2));
      expect(items.map((i) => i.id).toSet().length, lessThanOrEqualTo(2));
    });

    test('Should not leak capacity when item creation fails', () async {
      var fail = true;
      final pool = Pool<Item>(1, () async {
        if (fail) {
          throw Exception('creation failed');
        }
        return Item();
      });

      await expectLater(() => pool.take(), throwsException);
      expect(pool, poolState(1, 0, 0));

      fail = false;
      await pool.take();
      expect(pool, poolState(1, 1, 0));
    });

    test('Should wake queued waiter when item creation fails', () async {
      var fail = true;
      final pool = Pool<Item>(1, () async {
        await Future.delayed(const Duration(milliseconds: 50));
        if (fail) {
          fail = false;
          throw Exception('creation failed');
        }
        return Item();
      });

      // first take reserves the only slot and will fail creation,
      // second take queues up behind it
      final take1 = pool.take(timeout: Duration(seconds: 5));
      final take2 = pool.take(timeout: Duration(seconds: 5));

      await expectLater(take1, throwsException);

      // the queued waiter must be woken to create a replacement item
      // instead of waiting for the full timeout
      final watch = Stopwatch()..start();
      await take2;
      watch.stop();

      expect(watch.elapsed, lessThan(const Duration(seconds: 1)));
      expect(pool, poolState(1, 1, 0));
    });

    test('Should throw when giving an item that is not taken', () async {
      final pool = Pool(2, createItem);
      await pool.fill();

      // foreign item, never part of the pool
      expect(() => pool.give(Item()), throwsStateError);
      expect(pool, poolState(2, 2, 2));

      // double give
      final item = await pool.take();
      pool.give(item);
      expect(() => pool.give(item), throwsStateError);
      expect(pool, poolState(2, 2, 2));
    });

    test('Should not hand out the same item twice after double give', () async {
      final pool = Pool(2, createItem);
      await pool.fill();
      final item = await pool.take();
      pool.give(item);
      try {
        pool.give(item);
      } on StateError catch (_) {}

      final item1 = await pool.take();
      final item2 = await pool.take();
      expect(item1.id, isNot(equals(item2.id)));
    });

    test('Should throw when adopting an item already in the pool', () async {
      final pool = Pool(2, createItem);
      final item = Item();
      pool.adopt(item);
      expect(() => pool.adopt(item), throwsStateError);
      expect(pool, poolState(2, 1, 1));

      final taken = await pool.take();
      expect(() => pool.adopt(taken), throwsStateError);
      expect(pool, poolState(2, 1, 0));
    });

    test(
      'Should not finalize and remove items that are currently taken',
      () async {
        final completer = Completer<Item>();
        final pool = Pool(
          1,
          createItem,
          checkIsLive: checkLiveAlwaysOn,
          maxLifetime: Duration(milliseconds: 100),
          onRemoveItem: (i) async => completer.complete(i),
        );
        await pool.fill();
        await pool.take();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(completer.isCompleted, false);
      },
    );
  });
}

Future<bool> Function(Item) checkLiveWhereId(int id) {
  return (Item item) =>
      Future.delayed(Duration(milliseconds: 50)).then((_) => item.id == id);
}

class Item {
  static int idSeq = 0;
  final int id;

  Item() : id = idSeq++;
}

Future<Item> createItem() async {
  await Future.delayed(const Duration(milliseconds: 50));
  return Item();
}

Future<Item> createItemNever() async {
  await Completer().future;
  return Item();
}

Future<Item> createItemError() async {
  await Future.delayed(const Duration(milliseconds: 50));
  throw Exception('Could not create item');
}

Future<bool> checkLive(Item item) async {
  return true;
}

Future<bool> checkLiveNever(Item item) async {
  await Completer().future;
  return true;
}

Future<bool> checkLiveAlwaysOn(Item item) async {
  await Future.delayed(const Duration(milliseconds: 50));
  return true;
}

Future<bool> checkLiveAlwaysOff(Item item) async {
  await Future.delayed(const Duration(milliseconds: 50));
  return false;
}
