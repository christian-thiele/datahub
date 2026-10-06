String createHelloWorldMain(String projectName) =>
    '''import 'package:datahub/datahub.dart';
import 'package:$projectName/$projectName.dart';

void main(List<String> arguments) => runApp([
  const HelloWorldService(),
  Schedule.every('say-hello', sayHello, interval: Duration(seconds: 10)),
], arguments: arguments);

Future<void> sayHello(ScheduleRun run) async =>
    Find<HelloWorld>().find().sayHello(run.scheduledFor);
''';
