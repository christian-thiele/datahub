import 'package:datahub/datahub.dart';

import 'notification.dart';

class NotificationHub extends EventHubService {
  @override
  String get exchange => 'test_notification';

  late final notificationSend =
      event('test.notification.send', bean: NotificationTransferBean);

  late final notificationReceive =
      event('test.notification.receive', bean: NotificationTransferBean);

  late final notificationProcessed =
      ephemeral('test.notification.processed', bean: NotificationTransferBean);
}
