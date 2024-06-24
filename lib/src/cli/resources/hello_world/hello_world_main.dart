String createHelloWorldMain(String projectName) => '''import 'dart:io';


import 'package:$projectName/$projectName.dart';

void main(List<String> arguments) async {
  await ApplicationHost(
    [
      HelloWorldService.new,
    ],
    args: arguments,
    onInitialized: onInitialized,
  ).run();
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
