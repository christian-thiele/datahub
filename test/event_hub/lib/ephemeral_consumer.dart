import 'dart:async';

import 'package:datahub/datahub.dart';

import 'notification_hub.dart';

class EphemeralConsumer extends BaseService {
  final _subs = <StreamSubscription>[];

  var i = 0;
  void start() {
    final run = ++i;
    _subs.add(resolve<NotificationHub>()
        .notificationProcessed
        .getStream('info.x')
        .listen((event) {
      print('info.x: ${event.data.text}');
    }, onError: (error) {
      print('error ($run)x $error');
    }));

    _subs.add(resolve<NotificationHub>()
        .notificationProcessed
        .getStream('info.*')
        .listen((event) {
      print('info.*: ${event.data.text}');
    }, onError: (error) {
      print('error ($run)* $error');
    }));

    print('$run Listener started');
  }

  void stop() {
    _subs.forEach((element) {
      element.cancel();
    });
    _subs.clear();
    print('Listener stopped');
  }
}
