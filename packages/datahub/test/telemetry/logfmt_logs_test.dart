import 'dart:io';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/expect.dart';

import '_fake_stdout.dart';

void main() {
  declareTest(
    'logStdoutFormat logfmt',
    [],
    config: {
      'telemetry': {'logStdoutFormat': 'logfmt', 'logLevel': 'debug'},
    },
    () async {
      final buffer = StringBuffer();
      IOOverrides.runZoned(() {
        log('Short line');
        log.warn('Some line with \nline breaks and special chars "\'\\');
        log.error(
          'This is an error.',
          error: ApiRequestException.badRequest('This is bad.'),
        );
      }, stdout: () => FakeStdout(buffer));

      final lines = buffer
          .toString()
          .split('\n')
          .where((e) => e.isNotEmpty)
          .toList();
      expect(lines.length, equals(3));

      expect(lines[0], equals('severity="DEBUG" msg="Short line"'));
      expect(
        lines[1],
        equals(
          'severity="WARNING" msg="Some line with \\nline breaks and special chars \\"\'\\\\"',
        ),
      );
      expect(
        lines[2],
        equals(
          'severity="ERROR" msg="This is an error." error="400 This is bad."',
        ),
      );
    },
  );
}
