import 'dart:convert';
import 'dart:io';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/expect.dart';

import '_fake_stdout.dart';

void main() {
  declareTest(
    'logStdoutFormat json',
    [],
    config: {
      'telemetry': {'logStdoutFormat': 'json', 'logLevel': 'debug'},
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

      final lines = buffer.toString().split('\n').where((e) => e.isNotEmpty);
      expect(lines.length, equals(3));
      final messages = [for (final line in lines) jsonDecode(line)];
      expect(messages[0]['severity'], equals('DEBUG'));
      expect(messages[0]['msg'], equals('Short line'));
      expect(messages[1]['severity'], equals('WARNING'));
      expect(
        messages[1]['msg'],
        equals('Some line with \nline breaks and special chars "\'\\'),
      );
      expect(messages[2]['severity'], equals('ERROR'));
      expect(messages[2]['msg'], equals('This is an error.'));
      expect(messages[2]['error'], equals('400 This is bad.'));
    },
  );
}
