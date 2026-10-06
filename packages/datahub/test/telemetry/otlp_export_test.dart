import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub/src/telemetry/opentelemetry-dart/open_telemetry.dart'
    as otel;
import 'package:datahub/test.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:test/test.dart';

/// An OpenTelemetry collector that keeps what it receives.
class _Collector {
  final traces = <otel.ExportTraceServiceRequest>[];
  final logs = <otel.ExportLogsServiceRequest>[];
  late final server = grpc.Server.create(
    services: [_TraceService(this), _LogsService(this)],
  );

  Iterable<otel.Span> get spans => traces
      .expand((r) => r.resourceSpans)
      .expand((r) => r.scopeSpans)
      .expand((s) => s.spans);

  Iterable<otel.LogRecord> get logRecords => logs
      .expand((r) => r.resourceLogs)
      .expand((r) => r.scopeLogs)
      .expand((s) => s.logRecords);

  Future<void> eventually(bool Function() condition) async {
    for (var i = 0; i < 100 && !condition(); i++) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    expect(condition(), isTrue);
  }
}

class _TraceService extends otel.TraceServiceBase {
  final _Collector collector;

  _TraceService(this.collector);

  @override
  Future<otel.ExportTraceServiceResponse> export(
    grpc.ServiceCall call,
    otel.ExportTraceServiceRequest request,
  ) async {
    collector.traces.add(request);
    return otel.ExportTraceServiceResponse();
  }
}

class _LogsService extends otel.LogsServiceBase {
  final _Collector collector;

  _LogsService(this.collector);

  @override
  Future<otel.ExportLogsServiceResponse> export(
    grpc.ServiceCall call,
    otel.ExportLogsServiceRequest request,
  ) async {
    collector.logs.add(request);
    return otel.ExportLogsServiceResponse();
  }
}

Future<void> main() async {
  final collector = _Collector();
  await collector.server.serve(port: 0);
  tearDownAll(() => collector.server.shutdown());

  declareTest(
    'Exports spans and logs to an OpenTelemetry collector',
    [],
    config: {
      'telemetry': {
        'serviceName': 'otlp-test',
        'openTelemetryExporter': {
          'enable': true,
          'host': 'localhost',
          'port': collector.server.port,
          'exportInterval': 100,
          'exportIntervalJitter': 0,
        },
      },
    },
    () async {
      final telemetry = Find<Telemetry>().find();
      late LocalSpan span;
      await telemetry.trace('work', (s) async {
        span = s;
        s.setAttribute('datahub.test.value', 42);
        log.warn('inside span');
      });

      await collector.eventually(
        () => collector.spans.any((s) => s.name == 'work'),
      );
      final exported = collector.spans.firstWhere((s) => s.name == 'work');
      expect(exported.traceId, equals(span.traceId.bytes));
      expect(exported.endTimeUnixNano.toInt(), greaterThan(0));
      expect(
        exported.attributes
            .firstWhere((a) => a.key == 'datahub.test.value')
            .value
            .intValue
            .toInt(),
        equals(42),
      );

      final resource = collector.traces.first.resourceSpans.single.resource;
      expect({
        for (final a in resource.attributes) a.key: a.value.stringValue,
      }, containsPair('service.name', 'otlp-test'));

      await collector.eventually(
        () => collector.logRecords.any(
          (l) => l.body.stringValue == 'inside span',
        ),
      );
      final record = collector.logRecords.firstWhere(
        (l) => l.body.stringValue == 'inside span',
      );
      expect(record.severityText, equals('WARN'));
      expect(record.traceId, equals(span.traceId.bytes));
      expect(record.spanId, equals(span.spanId.bytes));

      // exported on shutdown
      unawaited(telemetry.trace('last', (_) {}));
    },
  );

  test('Flushes spans when the telemetry is disposed', () {
    expect(collector.spans.map((s) => s.name), contains('last'));
  });
}
