import 'dart:io';

import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/scaffolding.dart';

import 'lib/calculator_service.dart';

void main() {
  TestHost([
    CalculatorService.new,
  ]).declare((host) {
    group('Isolated Service', () {
      host.test('Blocking tasks', () async {
        final resultTask = resolve<CalculatorService>().calculate('abc');
        // wait for sending
        await Future.delayed(const Duration(milliseconds: 1));
        print('main thread sleeps now');
        sleep(const Duration(seconds: 3));
        print('main thread awake again');
        print('result is ${await resultTask}');
      });
    });
  });
}
