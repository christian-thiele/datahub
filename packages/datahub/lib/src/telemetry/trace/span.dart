import 'dart:collection';
import 'dart:developer' as dev;

import '../logs/log_helper.dart';
import '../span_id.dart';
import '../trace_id.dart';
import 'event.dart';
import 'tracer.dart';

enum SpanType { internal, server, client, producer, consumer }

class Span {
  final TraceId traceId;
  final SpanId? parentSpanId;
  final SpanId spanId;

  Span({
    required this.traceId,
    required this.parentSpanId,
    required this.spanId,
  });
}

class LocalSpan extends Span {
  final Tracer tracer;
  final Span? parent;
  final String name;
  final SpanType? type;
  bool _hasError = false;

  dev.TimelineTask? _timelineTask;
  DateTime? _startTimestamp;
  DateTime? _endTimestamp;

  final Map<String, dynamic> _attributes;
  final _events = <Event>[];

  UnmodifiableMapView<String, dynamic> get attributes =>
      UnmodifiableMapView(_attributes);

  UnmodifiableListView<Event> get events => UnmodifiableListView(_events);

  DateTime? get startTimestamp => _startTimestamp;

  DateTime? get endTimestamp => _endTimestamp;

  bool get hasError => _hasError;

  LocalSpan({
    required this.tracer,
    required super.traceId,
    required super.spanId,
    required this.parent,
    required this.name,
    required Map<String, dynamic> attributes,
    required this.type,
  }) : _attributes = attributes,
       super(parentSpanId: parent?.spanId);

  void start() {
    try {
      if (_startTimestamp == null) {
        if (tracer.enableDartTimeline) {
          _timelineTask = dev.TimelineTask(
            parent: switch (parent) {
              LocalSpan(:final _timelineTask) => _timelineTask,
              _ => null,
            },
          );
          _timelineTask?.start(
            name,
            arguments: {
              'traceId': traceId.hexId,
              'spanId': spanId.hexId,
              ...attributes,
            },
          );
        }
        _startTimestamp = DateTime.timestamp();
      }
    } catch (e, stack) {
      log.error('Could not start span.', error: e, stack: stack);
    }
  }

  void setHasError() => _hasError = true;

  void addEvent(String name, {Map<String, dynamic>? arguments}) {
    _addEvent(
      Event(
        name: name,
        attributes: attributes,
        timestamp: DateTime.timestamp(),
      ),
    );
  }

  void addAttribute(String name, String value) {
    if (!_attributes.containsKey(name)) {
      _attributes[name] = value;
    }
  }

  void addExceptionEvent(dynamic error) {
    _addEvent(ExceptionEvent(error: error, timestamp: DateTime.timestamp()));
    setHasError();
  }

  void _addEvent(Event event) {
    try {
      _events.add(event);
      if (_timelineTask != null) {
        dev.TimelineTask(parent: _timelineTask).instant(
          event.name,
          arguments: {
            'traceId': traceId.hexId,
            'spanId': spanId.hexId,
            ...event.attributes,
          },
        );
      }
    } catch (e, stack) {
      log.error('Could not add trace event.', error: e, stack: stack);
    }
  }

  void stop() {
    if (_endTimestamp == null) {
      _timelineTask?.finish();
      _endTimestamp = DateTime.timestamp();
    }
  }
}
