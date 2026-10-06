import 'dart:typed_data';

import 'package:datahub/datahub.dart';
import 'package:datahub/src/telemetry/opentelemetry-dart/open_telemetry.dart'
    as otel;
import 'package:datahub/src/telemetry/otlp/otlp_mapping.dart';
import 'package:datahub/test.dart';
import 'package:grpc/grpc.dart';
import 'package:test/test.dart';

/// Captures the spans it would send to a collector.
class _CapturingExporter extends OpenTelemetryTraceExporter {
  final sent = <otel.Span>[];

  _CapturingExporter()
    : super(
        channel: ClientChannel('localhost'),
        exportInterval: const Duration(hours: 1),
        exportIntervalJitter: Duration.zero,
      );

  @override
  Future<void> send(otel.ExportTraceServiceRequest request) async {
    for (final resource in request.resourceSpans) {
      for (final scope in resource.scopeSpans) {
        sent.addAll(scope.spans);
      }
    }
  }
}

Tracer _tracer(TraceExporter exporter, [String name = 'test']) => Tracer(
  name: name,
  version: null,
  enableDartTimeline: false,
  attributes: const {},
  exporter: exporter,
);

void main() {
  group('Tracer', () {
    test('spans of different tracers share the active span', () async {
      final exporter = DiscardTraceExporter();
      final a = _tracer(exporter, 'a');
      final b = _tracer(exporter, 'b');

      await a.trace('outer', (outer) async {
        expect(Tracer.currentSpan, same(outer));
        await b.trace('inner', (inner) async {
          expect(inner.parent, same(outer));
          expect(inner.traceId, equals(outer.traceId));
          expect(b.findParentSpan(), same(inner));
        });
      });
      expect(Tracer.currentSpan, isNull);
    });

    test('continues remote parents and their trace flags', () async {
      final exporter = _CapturingExporter();
      final tracer = _tracer(exporter);
      final remote = TraceContext.parse(
        '00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01',
      )!;

      await tracer.trace('sampled', (span) {
        expect(span.traceId, equals(remote.traceId));
        expect(span.parentSpanId, equals(remote.spanId));
        expect(span.isSampled, isTrue);
      }, parent: remote);

      final unsampled = Span.remote(
        traceId: remote.traceId,
        spanId: remote.spanId,
        traceFlags: 0,
      );
      await tracer.trace('unsampled', (span) {
        expect(span.isSampled, isFalse);
      }, parent: unsampled);

      await exporter.flush();
      expect(exporter.sent.map((s) => s.name), equals(['sampled']));
    });

    test('records exceptions and fails the span', () async {
      final tracer = _tracer(DiscardTraceExporter());
      late LocalSpan failed;
      await expectLater(
        tracer.trace('failing', (span) {
          failed = span;
          throw StateError('boom');
        }),
        throwsStateError,
      );

      expect(failed.isEnded, isTrue);
      expect(failed.hasError, isTrue);
      expect(failed.errorDescription, equals('Bad state: boom'));
      final event = failed.events.single;
      expect(event.name, equals('exception'));
      expect(event.attributes['exception.type'], equals('StateError'));
      expect(event.attributes['exception.message'], equals('Bad state: boom'));
      expect(event.attributes['exception.stacktrace'], isA<String>());
    });

    test('ignores changes after the span ended', () async {
      final tracer = _tracer(DiscardTraceExporter());
      final span = tracer.startSpan('span');
      span.end();
      span.setAttribute('late', true);
      span.setError();
      span.updateName('renamed');

      expect(span.attributes, isEmpty);
      expect(span.hasError, isFalse);
      expect(span.name, equals('span'));
    });
  });

  group('OpenTelemetryTraceExporter', () {
    test('sends spans that ended before the export once', () async {
      final exporter = _CapturingExporter();
      await _tracer(exporter).trace('short', (_) {});

      await exporter.flush();
      await exporter.flush();
      expect(exporter.sent, hasLength(1));
      expect(exporter.sent.single.endTimeUnixNano.toInt(), greaterThan(0));
    });

    test('sends running spans again once they ended', () async {
      final exporter = _CapturingExporter();
      final span = _tracer(exporter).startSpan('long');

      await exporter.flush();
      expect(exporter.sent.single.endTimeUnixNano.toInt(), equals(0));
      expect(
        exporter.sent.single.status.code,
        equals(otel.Status_StatusCode.STATUS_CODE_UNSET),
      );

      span.setAttribute('done', true);
      span.setError('failed');
      span.end();
      await exporter.flush();

      expect(exporter.sent, hasLength(2));
      final last = exporter.sent.last;
      expect(last.spanId, equals(exporter.sent.first.spanId));
      expect(last.endTimeUnixNano.toInt(), greaterThan(0));
      expect(last.status.code, otel.Status_StatusCode.STATUS_CODE_ERROR);
      expect(last.status.message, equals('failed'));
      expect(last.attributes.single.key, equals('done'));
    });
  });

  group('TraceContext', () {
    test('parses and formats traceparent', () {
      const header = '00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01';
      final span = TraceContext.parse(header)!;
      expect(span.traceId.hexId, equals('0af7651916cd43dd8448eb211c80319c'));
      expect(span.spanId.hexId, equals('b7ad6b7169203331'));
      expect(span.isSampled, isTrue);
      expect(span.isRemote, isTrue);
      expect(TraceContext.format(span), equals(header));
      expect(
        TraceContext.fromHeaders({
          'TraceParent': [header],
        })?.spanId,
        equals(span.spanId),
      );
    });

    test('rejects invalid traceparent', () {
      for (final header in [
        null,
        '',
        'garbage',
        // all zero ids
        '00-00000000000000000000000000000000-b7ad6b7169203331-01',
        '00-0af7651916cd43dd8448eb211c80319c-0000000000000000-01',
        // invalid version, extra fields in version 00, uppercase
        'ff-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01',
        '00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01-x',
        '00-0AF7651916CD43DD8448EB211C80319C-b7ad6b7169203331-01',
      ]) {
        expect(TraceContext.parse(header), isNull, reason: header);
      }
      // future versions may have more fields
      expect(
        TraceContext.parse(
          '01-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01-x',
        ),
        isNotNull,
      );
    });
  });

  group('OTLP mapping', () {
    test('converts attribute values', () {
      expect(
        otlpValue([1, 2]).arrayValue.values.map((v) => v.intValue.toInt()),
        equals([1, 2]),
      );
      expect(otlpValue(Uint8List.fromList([1, 2])).bytesValue, equals([1, 2]));
      expect(otlpValue({'a': 1}).stringValue, equals('{"a":1}'));
      expect(otlpValue(1.5).doubleValue, equals(1.5));
      expect(otlpValue(true).boolValue, isTrue);
      expect(otlpAttributes({'a': null, 'b': 'x'}).map((e) => e.key), ['b']);
    });

    test('converts log messages', () {
      final span = Span.remote(
        traceId: TraceId.generate(),
        spanId: SpanId.generate(),
      );
      final record = otlpLogRecord(
        LogMessage(
          timestamp: DateTime.timestamp(),
          line: 'Something failed.',
          level: SeverityLevel.warning,
          labels: {'datahub.task.id': 'task'},
          error: StateError('boom'),
          stack: StackTrace.current,
          span: span,
        ),
      );

      expect(record.severityText, equals('WARN'));
      expect(
        record.severityNumber,
        equals(otel.SeverityNumber.SEVERITY_NUMBER_WARN),
      );
      expect(record.body.stringValue, equals('Something failed.'));
      expect(record.traceId, equals(span.traceId.bytes));
      expect(record.spanId, equals(span.spanId.bytes));
      expect(
        record.attributes.map((e) => e.key),
        containsAll([
          'datahub.task.id',
          'exception.type',
          'exception.message',
          'exception.stacktrace',
        ]),
      );
    });
  });

  declareTest('Telemetry publishes ended spans', [], () async {
    final telemetry = Find<Telemetry>().find();
    final ended = <LocalSpan>[];
    final subscription = telemetry.endedSpans.listen(ended.add);

    await telemetry.trace('outer', (outer) async {
      await telemetry.getTracer('other').trace('inner', (_) {});
      expect(ended.map((s) => s.name), equals(['inner']));
    });

    expect(ended.map((s) => s.name), equals(['inner', 'outer']));
    expect(ended.first.parent, same(ended.last));
    await subscription.cancel();
  });
}
