import 'dart:async';

import 'package:meta/meta.dart';

import '../span_id.dart';
import '../telemetry_scope.dart';
import '../trace_id.dart';
import 'span.dart';
import 'trace_exporter.dart';

class Tracer implements TelemetryScope {
  /// Zone key of the active span, shared by all tracers so spans of
  /// different tracers (and logs) see the same parent.
  static const _activeSpanKey = #datahub.telemetry.activeSpan;

  @override
  final String name;
  @override
  final String? version;
  @override
  final Map<String, dynamic> attributes;

  late final String key = buildKey(name, version);

  final bool enableDartTimeline;

  final TraceExporter _exporter;
  final void Function(LocalSpan span)? _onEnd;

  Tracer({
    required this.name,
    required this.version,
    required this.enableDartTimeline,
    required this.attributes,
    required TraceExporter exporter,
    void Function(LocalSpan span)? onEnd,
  }) : _exporter = exporter,
       _onEnd = onEnd;

  static String buildKey(String name, String? version) =>
      version == null ? name : '$name@$version';

  /// The active span of the current zone, regardless of the tracer that
  /// created it.
  static Span? get currentSpan => switch (Zone.current[_activeSpanKey]) {
    final Span span => span,
    _ => null,
  };

  /// Runs [delegate] in a new span, which is ended when [delegate] returns.
  ///
  /// The span is a child of [parent], or of [currentSpan] if [parent] is
  /// null. Exceptions thrown by [delegate] are recorded on the span (which
  /// fails it) and rethrown.
  Future<R> trace<R>(
    String name,
    FutureOr<R> Function(LocalSpan span) delegate, {
    SpanType type = SpanType.internal,
    Map<String, Object?>? attributes,
    Span? parent,
  }) async {
    final span = startSpan(
      name,
      attributes: attributes,
      type: type,
      parent: parent,
    );

    try {
      return await runInSpanZone(span, delegate);
    } finally {
      span.end();
    }
  }

  /// Starts a span, which has to be ended by calling [LocalSpan.end].
  ///
  /// Prefer [trace], which also makes the span the active span of the code
  /// it runs. See [trace] for [parent].
  ///
  /// [startTimestamp] backdates the span, e.g. for an operation that started
  /// before the tracer was available, see [LocalSpan.start].
  LocalSpan startSpan(
    String name, {
    Map<String, Object?>? attributes,
    SpanType type = SpanType.internal,
    Span? parent,
    DateTime? startTimestamp,
  }) {
    final parentSpan = parent ?? currentSpan;
    final span = LocalSpan(
      tracer: this,
      traceId: parentSpan?.traceId ?? TraceId.generate(),
      spanId: SpanId.generate(),
      parent: parentSpan,
      name: name,
      attributes: {...?attributes},
      type: type,
      traceFlags: parentSpan?.traceFlags ?? Span.flagSampled,
    );
    span.start(startTimestamp);
    if (span.isSampled) {
      _exporter.onStart(span);
    }
    return span;
  }

  /// Runs [delegate] with [span] as active span. Exceptions thrown by
  /// [delegate] are recorded on [span] and rethrown.
  Future<R> runInSpanZone<R>(
    LocalSpan span,
    FutureOr<R> Function(LocalSpan span) delegate,
  ) async {
    return runZoned(() async {
      try {
        return await delegate(span);
      } catch (error, stack) {
        span.recordException(error, stack: stack);
        rethrow;
      }
    }, zoneValues: {_activeSpanKey: span});
  }

  /// The active span of the current zone, see [currentSpan].
  Span? findParentSpan() => currentSpan;

  /// Called by [LocalSpan.end].
  @internal
  void spanEnded(LocalSpan span) {
    if (span.isSampled) {
      _exporter.onEnd(span);
    }
    _onEnd?.call(span);
  }
}
