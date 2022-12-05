import 'package:datahub/broker.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

import 'lib/notification.dart';
import 'lib/notification_hub.dart';
import 'lib/notification_hub_consumer.dart';

void main() {
  final host = TestHost(
    [
      () => AmqpBrokerService('rabbit'),
      NotificationHub.new,
      NotificationHubConsumer.new,
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
      final listener = StreamBatchListener(hub.notificationReceive.stream);
      await hub.notificationSend
          .publish(Notification('Hello', 'Some text here', false));
      await Future.delayed(Duration(milliseconds: 100));
      expect(listener.hasNext, isFalse);
      await hub.notificationSend
          .publish(Notification('Hello', 'Other text', true));
      await Future.delayed(Duration(milliseconds: 100));
      expect(listener.hasNext, isTrue);

      expect(
          await listener.next,
          predicate<HubEvent<Notification>>(
              (n) => n.data.text == 'ECHO: Other text'));
    }));
  });
}
