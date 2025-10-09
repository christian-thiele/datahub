import 'dart:async';

import 'package:boost/boost.dart';

import '../telemetry_scope.dart';
import 'span.dart';
import 'span_id.dart';
import 'trace_id.dart';

class Tracer implements TelemetryScope {
  static const _tracerKeyPrefix = 'datahub_instrumentation_tracer';
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

  FutureOr<R> trace<R>(
    String name,
    Map<String, dynamic>? attributes,
    FutureOr<R> Function() delegate,
  ) {
    final span = startSpan(name, attributes);

    return runZoned(() async {
      try {
        return await delegate();
      } catch (error) {
        span.addExceptionEvent(error);
        rethrow;
      } finally {
        span.stop();
      }
    }, zoneValues: {_tracerSpanKey: span});
  }

  Span startSpan(
    String name,
    Map<String, dynamic>? attributes, {
    SpanType? type,
  }) {
    final parent = findParentSpan();
    final span = Span(
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

  Span? findParentSpan() {
    final span = Zone.current[_tracerSpanKey];
    if (span is Span) {
      return span;
    } else {
      return null;
    }
  }
}
