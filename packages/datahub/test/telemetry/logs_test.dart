import 'dart:convert';
import 'dart:io';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

import '_fake_stdout.dart';

void main() {
  declareTest('Nested log listeners receive all messages', [], () async {
    final outer = <String>[];
    final inner = <String>[];

    LogListener(onPublish: (m) => outer.add(m.line)).run(() {
      log.info('outer');
      LogListener(onPublish: (m) => inner.add(m.line)).run(() {
        log.info('inner');
      });
    });

    expect(outer, equals(['outer', 'inner']));
    expect(inner, equals(['inner']));
  });

  declareTest('Logs carry the span of any tracer', [], () async {
    final telemetry = Find<Telemetry>().find();
    final messages = <LogMessage>[];

    await LogListener(onPublish: messages.add).run(
      () => telemetry.getTracer('other').trace('span', (span) async {
        log.info('in span');
        expect(messages.single.span, same(span));
      }),
    );
  });

  declareTest(
    'Stdout logs contain the stack trace and trace context',
    [],
    config: {
      'telemetry': {'logStdoutFormat': 'json', 'logLevel': 'debug'},
    },
    () async {
      final telemetry = Find<Telemetry>().find();
      final buffer = StringBuffer();
      late LocalSpan span;
      await IOOverrides.runZoned(
        () => telemetry.trace('span', (s) async {
          span = s;
          log.warn(
            'Failed.',
            error: StateError('boom'),
            stack: StackTrace.current,
          );
        }),
        stdout: () => FakeStdout(buffer),
      );

      final message = jsonDecode(buffer.toString().trim()) as Map;
      expect(message['severity'], equals('WARN'));
      expect(message['error'], equals('Bad state: boom'));
      expect(message['stack'], contains('logs_test.dart'));
      expect(message['trace_id'], equals(span.traceId.hexId));
      expect(message['span_id'], equals(span.spanId.hexId));
    },
  );

  test('Severity levels are encoded as OpenTelemetry short names', () {
    const codec = JsonDataCodec();
    expect(codec.encodeEnum(SeverityLevel.warning), equals('warn'));
    expect(
      codec.decodeEnum('warn', SeverityLevel.values),
      equals(SeverityLevel.warning),
    );
    expect(
      codec.decodeEnum('debug', SeverityLevel.values),
      equals(SeverityLevel.debug),
    );
    expect(SeverityLevel.warning.severityText, equals('WARN'));
  });

  declareTest(
    'Log level is configured with OpenTelemetry short names',
    [],
    config: {
      'telemetry': {'logLevel': 'warn'},
    },
    () async {
      final messages = <LogMessage>[];
      final buffer = StringBuffer();
      IOOverrides.runZoned(() {
        LogListener(onPublish: messages.add).run(() {
          log.info('hidden');
          log.warn('shown');
        });
      }, stdout: () => FakeStdout(buffer));

      // listeners receive all levels, exporters only the configured ones
      expect(messages, hasLength(2));
      expect(buffer.toString(), isNot(contains('hidden')));
      expect(buffer.toString(), contains('shown'));
    },
  );
}
