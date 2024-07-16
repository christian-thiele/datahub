import 'dart:async';

import 'span.dart';
import 'span_id.dart';
import 'trace_id.dart';

class Tracer {
  static const _tracerKeyPrefix = 'datahub_instrumentation_tracer';
  late final _tracerSpanKey = '$_tracerKeyPrefix/$key';

  final String name;
  final String version;
  late final String key = buildKey(name, version);

  final bool enableDartTimeline;

  Tracer({
    required this.name,
    required this.version,
    required this.enableDartTimeline,
  });

  static String buildKey(String name, String version) => '$name@$version';

  FutureOr<R> trace<R>(
    String name,
    Map<String, dynamic>? attributes,
    FutureOr<R> Function() delegate,
  ) {
    final span = startSpan(name, attributes);

    return runZoned(
      () async {
        try {
          return await delegate();
        } catch (error) {
          span.addExceptionEvent(error);
          rethrow;
        } finally {
          span.stop();
        }
      },
      zoneValues: {
        _tracerSpanKey: span,
      },
    );
  }

  Span startSpan(String name, Map<String, dynamic>? attributes) {
    final parent = findParentSpan();
    final span = Span(
      tracer: this,
      traceId: parent?.traceId ?? TraceId.generate(),
      spanId: SpanId.generate(),
      parent: parent,
      name: name,
      attributes: attributes ?? <String, dynamic>{},
    );
    span.start();
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
