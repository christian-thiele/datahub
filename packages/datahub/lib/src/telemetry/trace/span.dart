import 'dart:collection';
import 'dart:developer' as dev;

import '../logs/log_helper.dart';
import '../span_id.dart';
import '../trace_id.dart';
import 'event.dart';
import 'tracer.dart';

/// The kind of a span, see [SpanKind](https://opentelemetry.io/docs/specs/otel/trace/api/#spankind).
///
/// * [server]: handling an incoming request (e.g. HTTP)
/// * [client]: an outgoing call (HTTP, database, cache)
/// * [producer] / [consumer]: creating / processing a message or a stored
///   event, e.g. a workflow step
/// * [internal]: everything else
enum SpanType { internal, server, client, producer, consumer }

/// The context of a span that is propagated to its children: trace id, span
/// id and trace flags.
///
/// A [Span] is either a [LocalSpan] created in this process or a remote one,
/// e.g. parsed from a `traceparent` header (see [TraceContext]) or from a
/// stored event.
class Span {
  /// The `sampled` trace flag. Spans of unsampled traces are not exported.
  static const flagSampled = 0x01;

  final TraceId traceId;
  final SpanId? parentSpanId;
  final SpanId spanId;

  /// W3C trace flags, see [flagSampled].
  final int traceFlags;

  /// Whether this span was created in another process.
  final bool isRemote;

  Span({
    required this.traceId,
    required this.parentSpanId,
    required this.spanId,
    this.traceFlags = flagSampled,
    this.isRemote = false,
  });

  /// The context of a span created in another process.
  Span.remote({
    required this.traceId,
    required this.spanId,
    this.traceFlags = flagSampled,
  }) : parentSpanId = null,
       isRemote = true;

  bool get isSampled => traceFlags & flagSampled != 0;
}

/// A span created in this process.
///
/// Spans are usually created by [Tracer.trace] (or `Telemetry.trace`), which
/// ends them when the traced code returns. Spans created by
/// [Tracer.startSpan] have to be ended by calling [end].
///
/// A span is handed to the exporter when it starts, so it is visible even if
/// it never ends (e.g. when the service crashes), and again when it ends if
/// it was exported while running. Changes after [end] are ignored.
class LocalSpan extends Span {
  final Tracer tracer;
  final Span? parent;
  final SpanType? type;
  String _name;
  bool _hasError = false;
  String? _errorDescription;

  dev.TimelineTask? _timelineTask;
  DateTime? _startTimestamp;
  DateTime? _endTimestamp;

  final Map<String, Object?> _attributes;
  final _events = <Event>[];

  String get name => _name;

  UnmodifiableMapView<String, Object?> get attributes =>
      UnmodifiableMapView(_attributes);

  UnmodifiableListView<Event> get events => UnmodifiableListView(_events);

  DateTime? get startTimestamp => _startTimestamp;

  DateTime? get endTimestamp => _endTimestamp;

  bool get isEnded => _endTimestamp != null;

  /// Whether the operation of this span failed, see [setError].
  bool get hasError => _hasError;

  /// Describes why the operation failed, if [hasError].
  String? get errorDescription => _errorDescription;

  LocalSpan({
    required this.tracer,
    required super.traceId,
    required super.spanId,
    required this.parent,
    required String name,
    required Map<String, Object?> attributes,
    required this.type,
    super.traceFlags,
  }) : _name = name,
       _attributes = attributes,
       super(parentSpanId: parent?.spanId);

  /// Starts the span at [timestamp], which defaults to now. Calling [start]
  /// again has no effect.
  ///
  /// The task on the Dart developer timeline always starts now, since it
  /// cannot be backdated.
  void start([DateTime? timestamp]) {
    if (_startTimestamp != null) {
      return;
    }

    _startTimestamp = timestamp ?? DateTime.timestamp();
    try {
      if (tracer.enableDartTimeline) {
        _timelineTask = dev.TimelineTask(
          parent: switch (parent) {
            LocalSpan(:final _timelineTask) => _timelineTask,
            _ => null,
          },
        );
        _timelineTask?.start(name, arguments: _timelineArguments(attributes));
      }
    } catch (e, stack) {
      log.error('Could not start span.', error: e, stack: stack);
    }
  }

  /// Replaces the name, e.g. once the route of a request is known.
  void updateName(String name) {
    if (!isEnded) {
      _name = name;
    }
  }

  /// Sets the attribute [name], replacing an existing value.
  ///
  /// Use the names of the semantic conventions where they exist, otherwise
  /// `datahub.<component>.<attribute>`. [value] should be a [String], [int],
  /// [double], [bool] or a [List] of those, other values are exported as
  /// their string representation.
  void setAttribute(String name, Object value) {
    if (!isEnded) {
      _attributes[name] = value;
    }
  }

  /// Marks the operation of this span as failed.
  ///
  /// Only call this for failures of the operation itself, e.g. not for
  /// client errors (4xx) of a server span.
  void setError([String? description]) {
    if (!isEnded) {
      _hasError = true;
      _errorDescription = description ?? _errorDescription;
    }
  }

  void addEvent(String name, {Map<String, Object?>? attributes}) {
    _addEvent(
      Event(
        name: name,
        attributes: attributes ?? const {},
        timestamp: DateTime.timestamp(),
      ),
    );
  }

  /// Records [error] as an `exception` event and marks the span as failed,
  /// unless [setError] is false (e.g. for errors caused by the caller).
  void recordException(
    Object error, {
    StackTrace? stack,
    bool setError = true,
  }) {
    _addEvent(
      ExceptionEvent(
        error: error,
        stack: stack,
        timestamp: DateTime.timestamp(),
      ),
    );
    if (setError) {
      this.setError(ExceptionEvent.messageOf(error));
    }
  }

  void _addEvent(Event event) {
    if (isEnded) {
      return;
    }

    _events.add(event);
    try {
      if (_timelineTask != null) {
        dev.TimelineTask(
          parent: _timelineTask,
        ).instant(event.name, arguments: _timelineArguments(event.attributes));
      }
    } catch (e, stack) {
      log.error('Could not add trace event.', error: e, stack: stack);
    }
  }

  /// Ends the span at [timestamp], which defaults to now. Calling [end] again
  /// has no effect.
  void end([DateTime? timestamp]) {
    if (_endTimestamp == null) {
      _endTimestamp = timestamp ?? DateTime.timestamp();
      _timelineTask?.finish();
      tracer.spanEnded(this);
    }
  }

  Map<String, String> _timelineArguments(Map<String, Object?> attributes) => {
    'traceId': traceId.hexId,
    'spanId': spanId.hexId,
    for (final MapEntry(:key, :value) in attributes.entries) key: '$value',
  };
}
