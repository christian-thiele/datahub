String createHelloWorldMain(String projectName) => '''import 'dart:io';

import 'package:datahub/datahub.dart';
import 'package:$projectName/$projectName.dart';

void main(List<String> arguments) async {
  await ServiceHost(
    [
      HelloWorldService.new,
    ],
    args: arguments,
    onInitialized: onInitialized,
  ).run();

  // required because of signal catching inside ServiceHost
  exit(0);
}

void onInitialized() {
  final schedulerService = resolve<SchedulerService>();
  final helloService = resolve<HelloWorldService>();

  schedulerService.schedule(
    () => helloService.sayHello(DateTime.now().toString()),
    RepeatSchedule(const Duration(seconds: 10), false),
  );
}
''';
