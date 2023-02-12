import 'dart:async';

import 'package:datahub/datahub.dart';

import 'notification_hub.dart';

class EphemeralConsumer extends BaseService {
  final _subs = <StreamSubscription>[];

  void start() {
    _subs.add(resolve<NotificationHub>()
        .notificationProcessed
        .getStream('info.x')
        .listen((event) {
      print('info.x: ${event.data.text}');
    }));

    _subs.add(resolve<NotificationHub>()
        .notificationProcessed
        .getStream('info.*')
        .listen((event) {
      print('info.*: ${event.data.text}');
    }));
  }

  void stop() {
    _subs.forEach((element) {
      element.cancel();
    });
  }
}
