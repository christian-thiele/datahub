import 'dart:async';
import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

void main() {
  final host = TestHost(
    [
      () => AmqpBrokerService('rabbit'),
    ],
    config: {
      'datahub': {
        'serviceName': 'unit-test',
      },
      'rabbit': {
        'host': 'rabbit',
        'user': 'testuser',
        'password': 'secretpassword',
      },
    },
  );

  group('AMQP', () {
    test('Connection', host.test(() async {
      final amqp = resolve<AmqpBrokerService>();
      final sendChannel = await amqp.openChannel(prefetch: 1);
      final sendX = await sendChannel.declareExchange(
          'test-exchange', BrokerExchangeType.fanOut);
      await sendX.publish(utf8.encode('MESSAGE 1').asUint8List(), null);
      unawaited(Future.delayed(Duration(minutes: 10)).then((value) async =>
          await sendX.publish(utf8.encode('MESSAGE 2').asUint8List(), null)));

      final rcvChannel = await amqp.openChannel(prefetch: 3);
      final rcvX = await rcvChannel.declareExchange(
          'test-exchange', BrokerExchangeType.fanOut);
      final rcvQ = await rcvX.declareAndBindQueue('test-queue', []);
      rcvQ.getConsumer(noAck: false).listen((event) {
        print(utf8.decode(event.payload));
      }, onDone: () {
        print('DONE');
      }, onError: (e) {
        print('ERROR: $e');
      });
    }), timeout: Timeout(const Duration(minutes: 15)));
  });
}
