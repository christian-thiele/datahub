import 'package:datahub/datahub.dart';

import 'notification.dart';

class NotificationHub extends EventHubService {
  @override
  String get exchange => 'test_notification';

  late final notificationSend = event<Notification>('test.notification.send');

  late final notificationReceive =
      event<Notification>('test.notification.receive');
}
