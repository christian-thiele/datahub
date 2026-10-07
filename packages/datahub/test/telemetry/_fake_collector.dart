import 'package:datahub/src/telemetry/opentelemetry-dart/open_telemetry.dart'
    as otel;
import 'package:grpc/grpc.dart' as grpc;
import 'package:test/test.dart';

/// An OpenTelemetry collector that keeps what it receives.
class FakeCollector {
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
  final FakeCollector collector;

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
  final FakeCollector collector;

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
