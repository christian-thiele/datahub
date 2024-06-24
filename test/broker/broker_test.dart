import 'dart:async';
import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

void main() {
  TestHost(
    [() => AmqpBrokerService('rabbit')],
    args: ['test/config.yaml'],
  ).declare((host) {
    group('AMQP', () {
      host.test('Connection', () async {
        final amqp = resolve<AmqpBrokerService>();

        final sendChannel = await amqp.openChannel(prefetch: 1);
        final sendX = await sendChannel.declareExchange(
            'test-exchange', BrokerExchangeType.fanOut);

        final rcvChannel = await amqp.openChannel(prefetch: 3);
        final rcvX = await rcvChannel.declareExchange(
            'test-exchange', BrokerExchangeType.fanOut);
        final rcvQ = await rcvX.declareAndBindQueue('test-queue', []);

        final valueCompleter = Completer<String>();

        final subscription = rcvQ.getConsumer(noAck: false).listen((event) {
          if (!valueCompleter.isCompleted)
            valueCompleter.complete(utf8.decode(event.payload));
        }, onError: (e) {
          fail(e.toString());
        });

        await Future.delayed(Duration(seconds: 3));
        await sendX.publish(utf8.encode('MESSAGE').asUint8List(), null);
        expect(await valueCompleter.future, equals('MESSAGE'));
        await subscription.cancel();
      }, timeout: Timeout(const Duration(minutes: 1)));
    });
  });
}
