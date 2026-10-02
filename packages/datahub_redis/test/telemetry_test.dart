import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub_redis/datahub_redis.dart';
import 'package:test/test.dart';

import 'utils/redis_test_utils.dart';

/// The value of the sample [name] with exactly [labels], or null if it was
/// not exported.
Future<num?> _metric(
  String name, [
  Map<String, String> labels = const {},
]) async {
  final groups = await Find<Telemetry>().find().scrapeMetrics();
  for (final sample in groups.expand((g) => g.samples)) {
    if (sample.name == name && equals(labels).matches(sample.labels, {})) {
      return sample.value;
    }
  }
  return null;
}

void main() {
  redisGroup('Redis telemetry', (env) {
    env.test('counts commands by class and status', (redis) async {
      await redis.set('key', 'value');
      await redis.get('key');
      await redis.get('key');

      expect(
        await _metric('redis_commands_total', {
          'command_class': 'write',
          'status': 'ok',
        }),
        // FLUSHALL of the test setup is not a write
        equals(1),
      );
      expect(
        await _metric('redis_commands_total', {
          'command_class': 'read',
          'status': 'ok',
        }),
        equals(2),
      );
      expect(
        await _metric('redis_command_duration_seconds_count', {
          'command_class': 'read',
        }),
        equals(2),
      );
    });

    env.test('counts errors by kind', (redis) async {
      await redis.set('key', 'value');
      await expectLater(
        redis.lpush('key', ['x']),
        throwsA(isA<RedisServerException>()),
      );

      expect(
        await _metric('redis_errors_total', {'kind': 'server'}),
        equals(1),
      );
      expect(
        await _metric('redis_commands_total', {
          'command_class': 'write',
          'status': 'error',
        }),
        equals(1),
      );
      expect(
        await _metric('redis_errors_total', {'kind': 'timeout'}),
        equals(0),
      );
    });

    env.test('counts timeouts and closed connections', (redis) async {
      await expectLater(
        redis.execute([
          'BLPOP',
          'queue',
          5,
        ], timeout: const Duration(milliseconds: 100)),
        throwsA(isA<TimeoutException>()),
      );

      expect(await _metric('redis_command_timeouts_total'), equals(1));
      expect(
        await _metric('redis_errors_total', {'kind': 'timeout'}),
        equals(1),
      );
      expect(
        await _metric('redis_connections_closed_total', {'reason': 'timeout'}),
        equals(1),
      );
    });

    env.test('counts script cache misses', (redis) async {
      await redis.eval(const RedisScript('return 1'));
      await redis.eval(const RedisScript('return 1'));

      expect(await _metric('redis_script_cache_misses_total'), equals(1));
    });

    env.test('reports pool usage', (redis) async {
      expect(await _metric('redis_pool_size_target'), equals(2));
      expect(
        await _metric('redis_connections_opened_total'),
        greaterThanOrEqualTo(2),
      );

      await redis.useConnection((connection) async {
        expect(await _metric('redis_pool_size_in_use'), equals(1));
      });
      // the connection is reset before it counts as available again
      await eventually(
        () async => await _metric('redis_pool_size_in_use') == 0,
      );
      expect(
        await _metric('redis_pool_wait_seconds_count'),
        greaterThanOrEqualTo(1),
      );
    }, config: {'targetPoolSize': 2});

    env.test('counts rejected pool requests', (redis) async {
      final blocker = Completer<void>();
      final held = redis.useConnection((_) => blocker.future);
      await eventually(
        () async => await _metric('redis_pool_size_in_use') == 1,
      );

      final queued = redis.get('a').then<void>((_) {}, onError: (_) {});
      await expectLater(
        redis.get('b'),
        throwsA(isA<PoolQueueLimitException>()),
      );
      expect(await _metric('redis_pool_rejected_total'), equals(1));

      blocker.complete();
      await held;
      await queued;
    }, config: {'targetPoolSize': 1, 'poolQueueLimit': 1});

    env.test('tracks locks', (redis) async {
      final locks = Find<LockProvider<String>>().find();
      final handle = await locks.acquireLock('job');
      expect(await _metric('redis_locks_acquired_total'), equals(1));
      expect(await _metric('redis_locks_held'), equals(1));

      expect(await locks.tryAcquireLock('job'), isNull);
      expect(await _metric('redis_locks_contended_total'), equals(1));
      expect(await _metric('redis_locks_acquired_total'), equals(1));

      await handle.release();
      expect(await _metric('redis_locks_held'), equals(0));
      expect(await _metric('redis_lock_hold_seconds_count'), equals(1));
      expect(await _metric('redis_lock_wait_seconds_count'), equals(1));
    });

    env.test('tracks Pub/Sub', (redis) async {
      final messages = <RedisMessage>[];
      final subscription = redis.subscribe('news').listen(messages.add);
      await eventually(
        () async => await _metric('redis_subscriber_connected') == 1,
      );
      expect(await _metric('redis_subscriptions'), equals(1));
      await eventually(
        () async =>
            (await redis.execute([
              'PUBSUB',
              'NUMSUB',
              'news',
            ])).asList![1].asInt ==
            1,
      );

      await redis.publish('news', 'hello');
      await eventually(() => messages.length == 1);
      expect(await _metric('redis_pubsub_messages_received_total'), equals(1));

      await subscription.cancel();
      expect(await _metric('redis_subscriptions'), equals(0));
    });

    env.test('does not publish metrics when disabled', (redis) async {
      await redis.set('key', 'value');
      expect(
        await _metric('redis_commands_total', {
          'command_class': 'write',
          'status': 'ok',
        }),
        isNull,
      );
    }, config: {'enableMetrics': false});

    env.test('uses the configured metric prefix', (redis) async {
      await redis.get('key');
      expect(await _metric('cache_pool_size_target'), isNotNull);
      expect(await _metric('redis_pool_size_target'), isNull);
    }, config: {'metricPrefix': 'cache'});

    env.test('works with tracing enabled', (redis) async {
      await redis.set('key', 'value');
      expect(await redis.get('key'), equals('value'));
      await expectLater(
        redis.lpush('key', ['x']),
        throwsA(isA<RedisServerException>()),
      );

      expect(
        await redis.transaction((tx) {
          tx.set('a', '1');
        }),
        isTrue,
      );
      await redis.useConnection((connection) => connection.get('a'));
      await redis.scan().toList();

      final locks = Find<LockProvider<String>>().find();
      final handle = await locks.acquireLock('job');
      // contention is an expected outcome, not a failure of the acquisition
      expect(await locks.tryAcquireLock('job'), isNull);
      await handle.release();

      expect(
        await _metric('redis_commands_total', {
          'command_class': 'write',
          'status': 'ok',
        }),
        greaterThanOrEqualTo(1),
      );
    }, config: {'enableTracing': true});
  });
}
