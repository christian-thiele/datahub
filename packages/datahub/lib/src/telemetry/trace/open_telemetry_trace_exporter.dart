import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:meta/meta.dart';

import '../opentelemetry-dart/open_telemetry.dart' as otel;
import '../otlp/otlp_batch_exporter.dart';
import '../otlp/otlp_mapping.dart';
import 'span.dart';
import 'trace_exporter.dart';

enum _SpanState { queued, sentRunning, sent }

/// Exports spans to an OpenTelemetry collector via OTLP/gRPC.
///
/// Spans are queued when they start, so a span that never ends (e.g. when
/// the service crashes) is still visible. A span that was exported while it
/// was running is queued again when it ends, so the collector also receives
/// its final state.
class OpenTelemetryTraceExporter extends OtlpBatchExporter<LocalSpan>
    implements TraceExporter {
  final Map<String, Object?> resourceAttributes;
  final otel.TraceServiceClient _client;
  final _states = Expando<_SpanState>();

  OpenTelemetryTraceExporter({
    required ClientChannel channel,
    required super.exportInterval,
    required super.exportIntervalJitter,
    super.exportTimeout,
    super.maxBatchSize,
    super.maxBufferSize,
    this.resourceAttributes = const {},
  }) : _client = otel.TraceServiceClient(channel),
       super(signal: 'traces');

  @override
  Future<void> initialize() async => start();

  @override
  void onStart(LocalSpan span) {
    _states[span] = _SpanState.queued;
    enqueue(span);
  }

  @override
  void onEnd(LocalSpan span) {
    if (_states[span] == _SpanState.sentRunning) {
      _states[span] = _SpanState.queued;
      enqueue(span);
    }
  }

  @override
  Future<void> export(List<LocalSpan> batch) async {
    // the request is a snapshot of the spans, those still running are
    // queued again when they end
    final request = otlpTraceRequest(resourceAttributes, batch);
    for (final span in batch) {
      _states[span] = span.isEnded ? _SpanState.sent : _SpanState.sentRunning;
    }
    await send(request);
  }

  @override
  Iterable<LocalSpan> retryable(List<LocalSpan> batch) sync* {
    for (final span in batch) {
      // spans that ended in the meantime were queued again already
      if (_states[span] != _SpanState.queued) {
        _states[span] = _SpanState.queued;
        yield span;
      }
    }
  }

  /// Sends [request] to the collector.
  @protected
  Future<void> send(otel.ExportTraceServiceRequest request) =>
      _client.export(request);
}
