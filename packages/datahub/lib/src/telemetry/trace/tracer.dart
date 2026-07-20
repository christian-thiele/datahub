import 'dart:async';

import 'package:boost/boost.dart';

import '../span_id.dart';
import '../telemetry_scope.dart';
import '../trace_id.dart';
import 'span.dart';

class Tracer implements TelemetryScope {
  static const _tracerKeyPrefix = 'datahub_telemetry_tracer';
  late final _tracerSpanKey = '$_tracerKeyPrefix/$key';

  @override
  final String name;
  @override
  final String? version;
  @override
  final Map<String, dynamic> attributes;

  late final String key = buildKey(name, version);

  final bool enableDartTimeline;

  final Sink<Span> _sink;

  Tracer({
    required this.name,
    required this.version,
    required this.enableDartTimeline,
    required this.attributes,
    required Sink<Span> sink,
  }) : _sink = sink;

  static String buildKey(String name, String? version) =>
      '$name${version?.apply((v) => '@$v')}';

  Future<R> trace<R>(
    String name,
    Map<String, dynamic>? attributes,
    SpanType? type,
    FutureOr<R> Function(LocalSpan span) delegate,
  ) async {
    final span = startSpan(name, attributes, type: type);

    try {
      return await runInSpanZone(span, delegate);
    } finally {
      span.stop();
    }
  }

  LocalSpan startSpan(
    String name,
    Map<String, dynamic>? attributes, {
    SpanType? type,
  }) {
    final parent = findParentSpan();
    final span = LocalSpan(
      tracer: this,
      traceId: parent?.traceId ?? TraceId.generate(),
      spanId: SpanId.generate(),
      parent: parent,
      name: name,
      attributes: attributes ?? <String, dynamic>{},
      type: type,
    );
    span.start();
    _sink.add(span);
    return span;
  }

  Future<R> runInSpanZone<R>(
    LocalSpan span,
    FutureOr<R> Function(LocalSpan span) delegate,
  ) async {
    return runZoned(() async {
      try {
        return await delegate(span);
      } catch (error) {
        span.addExceptionEvent(error);
        rethrow;
      }
    }, zoneValues: {_tracerSpanKey: span});
  }

  Span? findParentSpan() => switch (Zone.current[_tracerSpanKey]) {
    final Span span => span,
    _ => null,
  };

  FutureOr<R> remoteSpan<R>(
    TraceId traceId,
    SpanId spanId,
    FutureOr<R> Function() delegate,
  ) {
    return runZoned(
      delegate,
      zoneValues: {
        _tracerSpanKey: Span(
          traceId: traceId,
          spanId: spanId,
          parentSpanId: null,
        ),
      },
    );
  }
}
