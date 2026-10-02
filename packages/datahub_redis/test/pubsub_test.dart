import 'dart:async';
import 'dart:typed_data';

import 'package:datahub_redis/datahub_redis.dart';
import 'package:test/test.dart';

import 'utils/redis_test_utils.dart';

/// Number of server-side subscriptions of [channel].
Future<int> _subscribers(Redis redis, String channel) async {
  final reply = await redis.execute(['PUBSUB', 'NUMSUB', channel]);
  return reply.asList![1].asInt!;
}

Future<int> _patternSubscriptions(Redis redis) async =>
    (await redis.execute(['PUBSUB', 'NUMPAT'])).asInt!;

void main() {
  redisGroup('Redis Pub/Sub', (env) {
    env.test('delivers published messages', (redis) async {
      final messages = <RedisMessage>[];
      final subscription = redis.subscribe('news').listen(messages.add);
      await eventually(() async => await _subscribers(redis, 'news') == 1);

      expect(await redis.publish('news', 'hello'), equals(1));
      await redis.publish('news', Uint8List.fromList([0, 255]));
      await redis.publish('other', 'ignored');
      await eventually(() => messages.length == 2);

      expect(messages.first.channel, equals('news'));
      expect(messages.first.pattern, isNull);
      expect(messages.first.payload, equals('hello'));
      expect(messages.last.data, equals([0, 255]));
      await subscription.cancel();
    });

    env.test('listeners share a single subscription', (redis) async {
      final first = <String>[];
      final second = <String>[];
      final stream = redis.subscribe('shared');
      final a = stream.listen((m) => first.add(m.payload));
      final b = redis.subscribe('shared').listen((m) => second.add(m.payload));
      await eventually(() async => await _subscribers(redis, 'shared') == 1);

      await redis.publish('shared', 'one');
      await eventually(() => first.length == 1 && second.length == 1);

      await a.cancel();
      await redis.publish('shared', 'two');
      await eventually(() => second.length == 2);
      expect(first, equals(['one']));

      await b.cancel();
      await eventually(() async => await _subscribers(redis, 'shared') == 0);
    });

    env.test('a stream can be listened to again', (redis) async {
      final stream = redis.subscribe('again');
      final first = stream.listen((_) {});
      await eventually(() async => await _subscribers(redis, 'again') == 1);
      await first.cancel();
      await eventually(() async => await _subscribers(redis, 'again') == 0);

      final messages = <String>[];
      final second = stream.listen((m) => messages.add(m.payload));
      await eventually(() async => await _subscribers(redis, 'again') == 1);
      await redis.publish('again', 'back');
      await eventually(() => messages.isNotEmpty);
      await second.cancel();
    });

    env.test('pattern subscriptions', (redis) async {
      final messages = <RedisMessage>[];
      final subscription = redis.psubscribe('orders.*').listen(messages.add);
      await eventually(() async => await _patternSubscriptions(redis) == 1);

      await redis.publish('orders.created', '42');
      await redis.publish('invoices.created', '43');
      await eventually(() => messages.isNotEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(messages, hasLength(1));
      expect(messages.single.pattern, equals('orders.*'));
      expect(messages.single.channel, equals('orders.created'));
      expect(messages.single.payload, equals('42'));

      await subscription.cancel();
      await eventually(() async => await _patternSubscriptions(redis) == 0);
    });

    env.test('re-subscribes after the connection was lost', (redis) async {
      final messages = <String>[];
      final channel = redis
          .subscribe('resilient')
          .listen((m) => messages.add(m.payload));
      final pattern = redis
          .psubscribe('resilient.*')
          .listen((m) => messages.add(m.payload));
      await eventually(() async => await _subscribers(redis, 'resilient') == 1);

      await redis.execute(['CLIENT', 'KILL', 'TYPE', 'pubsub']);
      await eventually(() async => await _subscribers(redis, 'resilient') == 0);
      await eventually(
        () async =>
            await _subscribers(redis, 'resilient') == 1 &&
            await _patternSubscriptions(redis) == 1,
      );

      await redis.publish('resilient', 'after');
      await redis.publish('resilient.x', 'pattern');
      await eventually(() => messages.length == 2);
      expect(messages, containsAll(['after', 'pattern']));

      await channel.cancel();
      await pattern.cancel();
    });

    test('streams are closed when the service is disposed', () async {
      final host = await env.startHost();
      final done = Completer<void>();
      host.redis.subscribe('closing').listen((_) {}, onDone: done.complete);
      await eventually(
        () async => await _subscribers(host.redis, 'closing') == 1,
      );

      await host.stop();
      await done.future.timeout(const Duration(seconds: 2));
    });
  });
}
