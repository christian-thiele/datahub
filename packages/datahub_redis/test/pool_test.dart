import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub_redis/datahub_redis.dart';
import 'package:test/test.dart';

import 'utils/redis_test_utils.dart';

Future<int> _clientId(RedisCommands redis) async =>
    (await redis.execute(['CLIENT', 'ID'])).asInt!;

void main() {
  redisGroup('Redis connection pool', (env) {
    const singleConnection = {'targetPoolSize': 1};

    env.test('selects the configured database', (redis) async {
      await redis.set('key', 'db3');
      final info = await redis.execute(['CLIENT', 'INFO']);
      expect(info.asString, contains(' db=3 '));
    }, config: {'database': 3});

    env.test('reports the client name', (redis) async {
      final name = await redis.execute(['CLIENT', 'GETNAME']);
      expect(name.asString, equals('my-redis-test'));
    }, config: {'serviceName': 'my redis test'});

    env.test('authenticates with username and password', (redis) async {
      final user = await redis.execute(['ACL', 'WHOAMI']);
      expect(user.asString, equals('default'));
    }, config: {'username': 'default'});

    env.test('restores the database on return', (redis) async {
      await redis.useConnection((connection) async {
        await connection.execute(['SELECT', 2]);
        await connection.set('key', 'db2');
      });

      expect(await redis.get('key'), isNull);
      final info = await redis.execute(['CLIENT', 'INFO']);
      expect(info.asString, contains(' db=0 '));
    }, config: singleConnection);

    env.test('unwatches keys on return', (redis) async {
      await redis.useConnection((connection) async {
        await connection.watch(['watched']);
      });
      await redis.set('watched', 'modified');

      // the same connection would abort if the key was still watched
      expect(await redis.transaction((tx) => tx.set('a', '1')), isTrue);
    }, config: singleConnection);

    env.test('discards an unfinished MULTI on return', (redis) async {
      await redis.useConnection((connection) async {
        await connection.execute(['MULTI']);
        await connection.execute(['SET', 'key', 'value']);
      });

      expect(await redis.get('key'), isNull);
      expect(await redis.ping(), equals('PONG'));
    }, config: singleConnection);

    env.test('replaces connections after AUTH', (redis) async {
      final before = await _clientId(redis);
      await redis.useConnection((connection) async {
        await connection.execute(['AUTH', redisPassword]);
      });

      expect(await _clientId(redis), isNot(equals(before)));
    }, config: singleConnection);

    env.test('nested calls reuse the bound connection', (redis) async {
      await redis.useConnection((connection) async {
        final id = await _clientId(connection);
        // would wait for the only connection if it took another one
        expect(await _clientId(redis), equals(id));
        await redis.useConnection(
          (nested) async => expect(await _clientId(nested), equals(id)),
        );
      });
    }, config: {...singleConnection, 'poolTimeout': 500});

    env.test('callbacks outliving useConnection take a new connection', (
      redis,
    ) async {
      late Future<void> delayed;
      final watch = Stopwatch()..start();
      await redis.useConnection((connection) async {
        delayed = Future<void>.delayed(
          const Duration(milliseconds: 50),
          () => redis.ping(),
        );
      });

      Duration? delayedDone;
      unawaited(delayed.then((_) => delayedDone = watch.elapsed));
      await redis.useConnection((connection) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        // the delayed ping must wait for this connection to be returned
        expect(delayedDone, isNull);
      });
      await delayed;
    }, config: singleConnection);

    env.test('recovers from connections closed by the server', (redis) async {
      final before = await _clientId(redis);
      await redis.execute(['CLIENT', 'KILL', 'TYPE', 'normal', 'SKIPME', 'no']);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(await redis.ping(), equals('PONG'));
      expect(await _clientId(redis), isNot(equals(before)));
    }, config: singleConnection);

    env.test('a timed out command does not break the pool', (redis) async {
      await expectLater(
        redis.execute([
          'BLPOP',
          'empty',
          5,
        ], timeout: const Duration(milliseconds: 100)),
        throwsA(isA<TimeoutException>()),
      );
      expect(await redis.ping(), equals('PONG'));
    }, config: singleConnection);

    env.test('blocking commands work with a longer timeout', (redis) async {
      Timer(
        const Duration(milliseconds: 100),
        () => redis.rpush('queue', ['job']),
      );
      final reply = await redis.execute([
        'BLPOP',
        'queue',
        2,
      ], timeout: const Duration(seconds: 5));
      expect(reply.asList!.map((e) => e.asString), ['queue', 'job']);
    });

    env.test('waiting for a connection times out', (redis) async {
      final holding = redis.useConnection(
        (connection) => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      await expectLater(redis.ping(), throwsA(isA<TimeoutException>()));
      await holding;
    }, config: {...singleConnection, 'poolTimeout': 100});

    env.test('idle connections are checked before use', (redis) async {
      // number of commands executed by the (only) pooled connection
      Future<int> commandCount() async {
        final info = (await redis.execute(['CLIENT', 'INFO'])).asString!;
        return int.parse(RegExp(r'tot-cmds=(\d+)').firstMatch(info)!.group(1)!);
      }

      final before = await commandCount();
      expect(await commandCount(), equals(before + 1));

      await Future<void>.delayed(const Duration(milliseconds: 300));
      // CLIENT INFO before plus the PING of the health check
      expect(await commandCount(), equals(before + 3));
    }, config: {...singleConnection, 'healthCheckInterval': 200});

    env.test('publishes pool metrics', (redis) async {
      final samples = await Find<Telemetry>().find().scrapeMetrics();
      final names = samples.map((s) => s.name).toSet();
      expect(
        names,
        containsAll([
          'redis_pool_size_target',
          'redis_pool_size_total',
          'redis_pool_size_available',
        ]),
      );
    });

    test('fails to start with a wrong password', () async {
      await expectLater(
        env.startHost(config: {'password': 'wrong'}),
        throwsA(isA<RedisServerException>()),
      );
    });
  });
}
