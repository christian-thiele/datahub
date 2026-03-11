import 'dart:io';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/expect.dart';

import '_fake_stdout.dart';

void main() {
  declareTest(
    'logStdoutFormat pretty',
    [],
    config: {
      'telemetry': {'logStdoutFormat': 'pretty'},
    },
    () async {
      final buffer = StringBuffer();
      IOOverrides.runZoned(() {
        log('Short line');
        log(
          'This is a very long line it is too long to fit on one pretty line so it should probably be broken into multiple lines in the terminal for better readability and to avoid the terminal from discarding characters that are too far beyond the size of the terminal which can be quite small if you really think about it.',
        );
        log('Some line with \nline breaks');
      }, stdout: () => FakeStdout(buffer));
      expect(buffer.isNotEmpty, isTrue);
    },
  );
}
