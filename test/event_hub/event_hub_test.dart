import 'package:datahub/broker.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

import 'lib/ephemeral_consumer.dart';
import 'lib/notification.dart';
import 'lib/notification_hub.dart';
import 'lib/notification_hub_consumer.dart';

void main() {
  final host = TestHost(
    [
      () => AmqpBrokerService('rabbit'),
      NotificationHub.new,
      NotificationHubConsumer.new,
      EphemeralConsumer.new,
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

  group('Event Hub', () {
    test('Simple Transfer', host.eventTest<NotificationHub>((hub) async {
      final listener =
          StreamBatchListener(hub.notificationReceive.getStream(prefetch: 3));
      await hub.notificationSend
          .publish(Notification('Hello', 'Some text here', false));
      await Future.delayed(Duration(milliseconds: 100));
      expect(listener.hasNext, isTrue);
      await hub.notificationSend
          .publish(Notification('Hello', 'Other text', true));
      await Future.delayed(Duration(milliseconds: 100));
      expect(listener.hasNext, isTrue);

      expect(
          await listener.next,
          predicate<HubEvent<Notification>>(
              (n) => n.data.text == 'ECHO: Other text'));
    }));

    test('Ephemeral', host.eventTest<NotificationHub>((hub) async {
      final listener = resolve<EphemeralConsumer>();
      listener.start();
      await Future.delayed(Duration(seconds: 1));
      await hub.notificationProcessed
          .publish('info.x', Notification('hi', 'this is x', false));
      await hub.notificationProcessed
          .publish('info.y', Notification('hi', 'this is y', false));
      await Future.delayed(Duration(seconds: 1));
      listener.stop();
      await Future.delayed(Duration(seconds: 1));
      await hub.notificationProcessed.publish(
          'info.x', Notification('hi', 'this is x but dropped', false));
      await Future.delayed(Duration(seconds: 1));
      listener.start();
      await hub.notificationProcessed
          .publish('info.x', Notification('hi', 'this is x', false));
      await hub.notificationProcessed.publish(
          'info2.y', Notification('hi', 'this is y but ignored', false));
    }));
  });
}
