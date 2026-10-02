import 'dart:typed_data';

import 'package:datahub/datahub.dart';
import 'package:datahub_redis/datahub_redis.dart';
import 'package:test/test.dart';

import 'utils/redis_test_utils.dart';

void main() {
  redisGroup('Redis commands', (env) {
    env.test('resolves as Redis and LockProvider<String>', (redis) async {
      expect(Find<Redis>().find(), same(redis));
      expect(Find<LockProvider<String>>().find(), same(redis));
      expect(await redis.ping(), equals('PONG'));
    });

    env.test('strings', (redis) async {
      expect(await redis.get('missing'), isNull);
      expect(await redis.set('greeting', 'hello wörld'), isTrue);
      expect(await redis.get('greeting'), equals('hello wörld'));

      expect(await redis.set('greeting', 'other', ifAbsent: true), isFalse);
      expect(await redis.set('fresh', 'value', ifExists: true), isFalse);
      expect(await redis.set('fresh', 'value', ifAbsent: true), isTrue);
      expect(await redis.set('fresh', 'updated', ifExists: true), isTrue);
      expect(await redis.get('fresh'), equals('updated'));

      expect(await redis.getdel('fresh'), equals('updated'));
      expect(await redis.exists('fresh'), isFalse);

      await redis.mset({'a': '1', 'b': 2, 'c': 3.5});
      expect(await redis.mget(['a', 'missing', 'b', 'c']), [
        '1',
        null,
        '2',
        '3.5',
      ]);
      expect(await redis.mget(['missing']), equals([null]));

      expect(
        () => redis.set('x', 'y', ifAbsent: true, ifExists: true),
        throwsArgumentError,
      );
    });

    env.test('binary values', (redis) async {
      final bytes = Uint8List.fromList([0, 1, 13, 10, 255, 254, 0]);
      await redis.set('binary', bytes);

      expect(await redis.getBytes('binary'), equals(bytes));
      await expectLater(redis.get('binary'), throwsFormatException);
      // the connection is still in sync after a decoding error
      expect(await redis.ping(), equals('PONG'));
      expect(await redis.getBytes('binary'), equals(bytes));
    });

    env.test('counters', (redis) async {
      expect(await redis.incr('counter'), equals(1));
      expect(await redis.incrby('counter', 10), equals(11));
      expect(await redis.decr('counter'), equals(10));
      expect(await redis.decrby('counter', 5), equals(5));
      expect(await redis.incrbyfloat('float', 1.5), equals(1.5));
      expect(await redis.incrbyfloat('float', -0.25), equals(1.25));

      await redis.set('text', 'abc');
      await expectLater(
        redis.incr('text'),
        throwsA(
          isA<RedisServerException>().having((e) => e.code, 'code', 'ERR'),
        ),
      );
    });

    env.test('expiration', (redis) async {
      await redis.set('temp', 'value', ttl: const Duration(seconds: 100));
      final ttl = await redis.ttl('temp');
      expect(ttl, isNotNull);
      expect(ttl!.inSeconds, inInclusiveRange(98, 100));

      expect(await redis.persist('temp'), isTrue);
      expect(await redis.ttl('temp'), isNull);
      expect(await redis.ttl('missing'), isNull);

      expect(
        await redis.expire('temp', const Duration(milliseconds: 100)),
        isTrue,
      );
      expect(
        await redis.expire('missing', const Duration(seconds: 1)),
        isFalse,
      );
      await eventually(() async => !await redis.exists('temp'));
    });

    env.test('keys', (redis) async {
      await redis.mset({'k1': 'a', 'k2': 'b', 'k3': 'c'});

      expect(await redis.del(['k1', 'k2', 'missing']), equals(2));
      expect(await redis.unlink(['k3']), equals(1));
      expect(await redis.exists('k3'), isFalse);
    });

    env.test('hashes', (redis) async {
      expect(await redis.hset('user', {'name': 'Ada', 'age': 36}), equals(2));
      expect(await redis.hset('user', {'age': 37, 'lang': 'en'}), equals(1));

      expect(await redis.hget('user', 'name'), equals('Ada'));
      expect(await redis.hget('user', 'missing'), isNull);
      expect(await redis.hmget('user', ['age', 'missing', 'lang']), [
        '37',
        null,
        'en',
      ]);
      expect(
        await redis.hgetall('user'),
        equals({'name': 'Ada', 'age': '37', 'lang': 'en'}),
      );
      expect(await redis.hgetall('missing'), isEmpty);
      expect(await redis.hexists('user', 'lang'), isTrue);
      expect(await redis.hincrby('user', 'age', 3), equals(40));
      expect(await redis.hdel('user', ['lang', 'missing']), equals(1));
      expect(await redis.hlen('user'), equals(2));
    });

    env.test('lists', (redis) async {
      expect(await redis.rpush('list', ['b', 'c']), equals(2));
      expect(await redis.lpush('list', ['a']), equals(3));
      expect(await redis.rpush('list', [4, 'e']), equals(5));

      expect(await redis.lrange('list', 0, -1), ['a', 'b', 'c', '4', 'e']);
      expect(await redis.llen('list'), equals(5));
      expect(await redis.lpop('list'), equals('a'));
      expect(await redis.rpop('list'), equals('e'));

      await redis.ltrim('list', 0, 0);
      expect(await redis.lrange('list', 0, -1), ['b']);
      expect(await redis.lpop('missing'), isNull);
    });

    env.test('sets', (redis) async {
      expect(await redis.sadd('set', ['a', 'b', 'a', 1]), equals(3));
      expect(await redis.smembers('set'), equals({'a', 'b', '1'}));
      expect(await redis.sismember('set', 'a'), isTrue);
      expect(await redis.sismember('set', 'z'), isFalse);
      expect(await redis.srem('set', ['a', 'z']), equals(1));
      expect(await redis.scard('set'), equals(2));
    });

    env.test('sorted sets', (redis) async {
      expect(
        await redis.zadd('scores', {
          'ada': 3,
          'bob': 1.5,
          'eve': double.infinity,
        }),
        equals(3),
      );
      expect(await redis.zrange('scores', 0, -1), ['bob', 'ada', 'eve']);
      expect(await redis.zscore('scores', 'bob'), equals(1.5));
      expect(await redis.zscore('scores', 'eve'), equals(double.infinity));
      expect(await redis.zscore('scores', 'missing'), isNull);
      expect(await redis.zincrby('scores', 2, 'bob'), equals(3.5));
      expect(await redis.zrem('scores', ['eve', 'missing']), equals(1));
      expect(await redis.zcard('scores'), equals(2));
    });

    env.test('execute returns raw replies', (redis) async {
      await redis.rpush('list', ['x', 'y']);

      expect(
        await redis.execute(['LRANGE', 'list', 0, -1]),
        equals(
          RedisArray([
            RedisBulkString.fromString('x'),
            RedisBulkString.fromString('y'),
          ]),
        ),
      );
      expect(
        await redis.execute(['TYPE', 'list']),
        equals(const RedisSimpleString('list')),
      );
      await expectLater(
        redis.execute(['NOSUCHCOMMAND']),
        throwsA(isA<RedisServerException>()),
      );
      await expectLater(redis.execute(['MONITOR']), throwsUnsupportedError);
    });

    env.test('eval falls back to EVAL when the script is not cached', (
      redis,
    ) async {
      const script = RedisScript(
        "return {KEYS[1], ARGV[1], redis.call('incr', KEYS[1])}",
      );
      await redis.execute(['SCRIPT', 'FLUSH']);

      final first = await redis.eval(script, keys: ['n'], args: ['arg']);
      expect(first.asList!.map((e) => e.asString), ['n', 'arg', '1']);

      final cached = await redis.execute([
        'SCRIPT',
        'EXISTS',
        script.sha1Digest,
      ]);
      expect(cached.asList!.single.asInt, equals(1));

      final second = await redis.eval(script, keys: ['n'], args: ['arg']);
      expect(second.asList!.last.asInt, equals(2));

      await expectLater(
        redis.eval(const RedisScript("return redis.error_reply('BOOM bad')")),
        throwsA(
          isA<RedisServerException>().having((e) => e.code, 'code', 'BOOM'),
        ),
      );
    });

    env.test('scan iterates all matching keys', (redis) async {
      await redis.mset({
        for (var i = 0; i < 250; i++) 'scan:$i': '$i',
        'other': 'x',
      });
      await redis.rpush('scan:list', ['x']);

      final keys = await redis.scan(match: 'scan:*', count: 20).toSet();
      expect(keys, hasLength(251));
      expect(keys, contains('scan:list'));
      expect(keys, isNot(contains('other')));

      final lists = await redis.scan(match: 'scan:*', type: 'list').toList();
      expect(lists, equals(['scan:list']));
    });

    env.test('pipelines commands on a single connection', (redis) async {
      final results = await redis.useConnection(
        (connection) => Future.wait([
          for (var i = 0; i < 1000; i++) connection.incr('pipelined'),
        ]),
      );
      expect(results, equals([for (var i = 1; i <= 1000; i++) i]));
    });

    env.test('concurrent commands beyond the pool size', (redis) async {
      final results = await Future.wait([
        for (var i = 0; i < 200; i++) redis.incr('concurrent'),
      ]);
      expect(results.toSet(), hasLength(200));
      expect(await redis.get('concurrent'), equals('200'));
    });
  });
}
