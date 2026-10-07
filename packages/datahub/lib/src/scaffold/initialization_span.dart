part of 'service_host.dart';

/// A span of the initialization of a [ServiceHost], see
/// [ServiceHost.initialize].
///
/// Spans can only be created once a [Telemetry] service is initialized, which
/// is itself part of the initialization. The [LocalSpan] is therefore created
/// lazily, backdated to when its component started to initialize, as soon as
/// the root of the initialization knows a tracer (see [useTelemetry]).
class _InitializationSpan {
  final String name;
  final _InitializationSpan? parent;

  /// The active span when the initialization started, the parent of the root.
  final Span? _callerSpan;
  final DateTime _startTimestamp = DateTime.timestamp();
  DateTime? _endTimestamp;

  /// The tracer of all spans of the initialization, only set on the root.
  Tracer? _tracer;

  /// The spans that ended before [_tracer] was known, only set on the root.
  final _endedWithoutTracer = <_InitializationSpan>[];

  LocalSpan? _span;

  _InitializationSpan.root(this.name)
    : parent = null,
      _callerSpan = Tracer.currentSpan;

  _InitializationSpan(this.name, {required _InitializationSpan this.parent})
    : _callerSpan = null;

  _InitializationSpan get _root => parent?._root ?? this;

  /// The span, if a tracer is known yet.
  LocalSpan? get _localSpan {
    if (_span case final span?) {
      return span;
    }

    if (_root._tracer case final tracer?) {
      return _span = tracer.startSpan(
        name,
        parent: parent?._localSpan ?? _callerSpan,
        startTimestamp: _startTimestamp,
      );
    }

    return null;
  }

  /// Creates the spans of the initialization with the default tracer of
  /// [telemetry], unless a tracer is known already.
  ///
  /// The spans that ended so far are created and ended right away, those
  /// still running once they are used.
  void useTelemetry(Telemetry telemetry) {
    final root = _root;
    if (root._tracer != null) {
      return;
    }

    root._tracer = telemetry.getDefaultTracer();
    for (final ended in root._endedWithoutTracer) {
      ended._localSpan?.end(ended._endTimestamp);
    }
    root._endedWithoutTracer.clear();
  }

  /// Runs [body] in this span and ends it, see [Tracer.trace].
  ///
  /// The span is only active for [body] if a tracer is known when it starts.
  Future<R> trace<R>(Future<R> Function() body) async {
    try {
      if (_localSpan case final span?) {
        return await span.tracer.runInSpanZone(span, (_) => body());
      }

      try {
        return await body();
      } catch (e, stack) {
        _localSpan?.recordException(e, stack: stack);
        rethrow;
      }
    } finally {
      _end();
    }
  }

  void _end() {
    if (_localSpan case final span?) {
      span.end();
    } else {
      _endTimestamp = DateTime.timestamp();
      _root._endedWithoutTracer.add(this);
    }
  }
}
