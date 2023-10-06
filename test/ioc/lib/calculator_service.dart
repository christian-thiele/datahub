import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:datahub/datahub.dart';

class CalculatorService extends IsolatedService {
  late final StreamSubscription _sub;

  @override
  Future<void> initializeIsolate(Stream<dynamic> receive) async {
    print('Hello from isolate.');
    print('Name of service is ${resolve<ConfigService>().serviceName}');

    _sub = receive.listen((event) {
      executeTask(event);
    });
  }

  @override
  Future<void> shutdownIsolate() async {
    print('shutting down isolate in 3 sec');
    await Future.delayed(const Duration(seconds: 3));
    await _sub.cancel();
    print('done');
  }

  static void executeTask(_CalculatorTask task) async {
    print('Received ${task.text}');
    print('Blocking for no good reason...');
    sleep(const Duration(seconds: 5));
    print('Returning ${task.text.length}');
    task.result.send(task.text.length);
  }

  Future<int> calculate(String text) async {
    final receivePort = ReceivePort();
    final task = _CalculatorTask(text, receivePort.sendPort);
    await send(task);
    return await receivePort.first;
  }
}

class _CalculatorTask {
  final String text;
  final SendPort result;

  _CalculatorTask(this.text, this.result);
}
