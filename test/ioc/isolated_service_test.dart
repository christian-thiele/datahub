import 'dart:io';

import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/scaffolding.dart';

import 'lib/calculator_service.dart';

void main() {
  final host = TestHost([
    CalculatorService.new,
  ]);

  group('Isolated Service', () {
    test('Blocking tasks', host.test(() async {
      final resultTask = resolve<CalculatorService>().calculate('abc');
      // wait for sending
      await Future.delayed(const Duration(milliseconds: 1));
      print('this thread sleeps now');
      sleep(const Duration(seconds: 5));
      print('awake again');
      print('result is ${await resultTask}');
    }));
  });
}
