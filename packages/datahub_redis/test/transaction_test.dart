import 'dart:async';

import 'package:datahub_redis/datahub_redis.dart';
import 'package:test/test.dart';

import 'utils/redis_test_utils.dart';

void main() {
  redisGroup('Redis transactions', (env) {
    env.test('executes queued commands and provides results', (redis) async {
      late Future<bool> set;
      late Future<int> incr;
      late Future<String?> get;
      final executed = await redis.transaction((tx) {
        set = tx.set('key', 'value');
        incr = tx.incr('counter');
        get = tx.get('key');
      });

      expect(executed, isTrue);
      expect(await set, isTrue);
      expect(await incr, equals(1));
      expect(await get, equals('value'));
    });

    env.test('a single command with a null result is no abort', (redis) async {
      late Future<String?> get;
      final executed = await redis.transaction((tx) {
        get = tx.get('missing');
      });

      expect(executed, isTrue);
      expect(await get, isNull);
    });

    env.test('an empty transaction executes', (redis) async {
      expect(await redis.transaction((tx) {}), isTrue);
    });

    env.test('runtime errors only fail the affected command', (redis) async {
      await redis.set('text', 'abc');

      late Future<int> failing;
      late Future<int> succeeding;
      final executed = await redis.transaction((tx) {
        failing = tx.incr('text');
        succeeding = tx.incr('number');
      });

      expect(executed, isTrue);
      await expectLater(failing, throwsA(isA<RedisServerException>()));
      expect(await succeeding, equals(1));
    });

    env.test('queue errors abort the whole transaction', (redis) async {
      late Future<bool> set;
      late Future<RedisReply> invalid;
      await expectLater(
        redis.transaction((tx) {
          set = tx.set('key', 'value');
          invalid = tx.execute(['NOSUCHCOMMAND']);
        }),
        throwsA(
          isA<RedisServerException>().having(
            (e) => e.code,
            'code',
            'EXECABORT',
          ),
        ),
      );

      await expectLater(set, throwsA(isA<RedisServerException>()));
      await expectLater(invalid, throwsA(isA<RedisServerException>()));
      expect(await redis.exists('key'), isFalse);
      // the connection left MULTI state
      expect(await redis.ping(), equals('PONG'));
    });

    env.test('a modified watched key aborts the transaction', (redis) async {
      final testZone = Zone.current;
      await redis.set('balance', '100');

      late Future<bool> set;
      final executed = await redis.useConnection((connection) async {
        await connection.watch(['balance']);
        final balance = int.parse((await connection.get('balance'))!);

        // modified by another connection between WATCH and EXEC
        await _onOtherConnection(testZone, () => redis.set('balance', '50'));
        return await connection.transaction((tx) {
          set = tx.set('balance', balance - 10);
        });
      });

      expect(executed, isFalse);
      await expectLater(set, throwsA(isA<RedisTransactionAbortedException>()));
      expect(await redis.get('balance'), equals('50'));
    });

    env.test('check-and-set retries until it succeeds', (redis) async {
      final testZone = Zone.current;
      await redis.set('balance', '100');
      var attempts = 0;

      await redis.useConnection((connection) async {
        while (true) {
          attempts++;
          await connection.watch(['balance']);
          final balance = int.parse((await connection.get('balance'))!);
          if (attempts == 1) {
            await _onOtherConnection(
              testZone,
              () => redis.incrby('balance', 5),
            );
          }
          final executed = await connection.transaction((tx) {
            tx.set('balance', balance - 10);
          });
          if (executed) {
            break;
          }
        }
      });

      expect(attempts, equals(2));
      expect(await redis.get('balance'), equals('95'));
    });

    env.test('commands cannot be queued after the callback', (redis) async {
      late RedisTransaction captured;
      await redis.transaction((tx) => captured = tx);

      expect(() => captured.get('key'), throwsStateError);
    });

    env.test('transaction control commands cannot be queued', (redis) async {
      await expectLater(
        redis.transaction((tx) => tx.execute(['EXEC'])),
        throwsUnsupportedError,
      );
      await expectLater(
        redis.transaction((tx) => tx.execute(['WATCH', 'key'])),
        throwsUnsupportedError,
      );
      expect(await redis.ping(), equals('PONG'));
    });

    env.test('an exception in the callback executes nothing', (redis) async {
      late Future<bool> set;
      await expectLater(
        redis.transaction((tx) {
          set = tx.set('key', 'value');
          throw StateError('failed');
        }),
        throwsStateError,
      );

      await expectLater(set, throwsStateError);
      expect(await redis.exists('key'), isFalse);
    });

    env.test('scripts in transactions use EVAL', (redis) async {
      await redis.execute(['SCRIPT', 'FLUSH']);
      late Future<RedisReply> result;
      await redis.transaction((tx) {
        result = tx.eval(const RedisScript('return ARGV[1]'), args: ['hi']);
      });

      expect((await result).asString, equals('hi'));
    });

    env.test('concurrent transactions on one connection do not interleave', (
      redis,
    ) async {
      final results = await redis.useConnection((connection) {
        return Future.wait([
          for (var i = 0; i < 20; i++)
            connection.transaction((tx) {
              tx.rpush('log', ['$i-a']);
              tx.rpush('log', ['$i-b']);
            }),
        ]);
      });

      expect(results, everyElement(isTrue));
      final log = await redis.lrange('log', 0, -1);
      for (var i = 0; i < log.length; i += 2) {
        expect(log[i].replaceAll('-a', ''), log[i + 1].replaceAll('-b', ''));
      }
    });

    env.test('ignored results of failed transactions are not unhandled', (
      redis,
    ) async {
      final testZone = Zone.current;
      await redis.set('watched', '1');
      await redis.useConnection((connection) async {
        await connection.watch(['watched']);
        await _onOtherConnection(testZone, () => redis.set('watched', '2'));
        final executed = await connection.transaction((tx) {
          tx.set('a', '1');
          tx.incr('b');
        });
        expect(executed, isFalse);
      });
      // unhandled errors would fail the test after this point
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
  });
}

/// Runs [body] in [zone], which must be outside of the zone bound by
/// `useConnection`, so that pooled commands take another connection.
Future<T> _onOtherConnection<T>(Zone zone, Future<T> Function() body) =>
    zone.run(body);
