import 'package:datahub/test.dart';
import 'package:test/test.dart';

import 'lib/notification.dart';
import 'lib/notification_hub.dart';
import 'lib/notification_hub_consumer.dart';

void main() {
  final host = TestHost([
    NotificationHub.new,
    NotificationHubConsumer.new,
  ]);

  group('Event Hub', () {
    test('Simple Transfer', host.eventTest<NotificationHub>((hub) async {
      final listener = StreamBatchListener(hub.notificationReceive.stream);
      hub.notificationSend
          .publish(Notification('Hello', 'Some text here', false));
      await Future.delayed(Duration(seconds: 1));
      expect(listener.hasNext, isFalse);

      hub.notificationSend.publish(Notification('Hello', 'Other text', true));
      await Future.delayed(Duration(seconds: 1));
      expect(await listener.next,
          predicate<Notification>((n) => n.text == 'Echo: Other text'));
    }));
  });
}
