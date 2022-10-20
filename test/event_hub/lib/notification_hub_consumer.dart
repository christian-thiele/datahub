import 'dart:async';

import 'package:datahub/broker.dart';

import 'notification.dart';
import 'notification_hub.dart';

class NotificationHubConsumer extends HubConsumerService<NotificationHub> {
  @override
  Future<void> initialize() async {
    listen(hub.notificationSend, _sendNotification);
  }

  FutureOr<void> _sendNotification(Notification event) async {
    if (event.receive) {
      hub.notificationReceive
          .publish(event.copyWith(text: 'ECHO: ${event.text}'));
    }
  }
}
