import 'dart:developer';

import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';

import 'event.dart';
import 'span_id.dart';
import 'trace_id.dart';
import 'tracer.dart';

class Span {
  final Tracer tracer;
  final TraceId traceId;
  final Span? parent;
  final SpanId spanId;
  final String name;

  TimelineTask? _timelineTask;
  DateTime? _startTimestamp;
  DateTime? _endTimestamp;
  final _events = <Event>[];
  final Map<String, dynamic> attributes;

  DateTime? get startTimestamp => _startTimestamp;

  DateTime? get endTimestamp => _endTimestamp;

  Span({
    required this.tracer,
    required this.traceId,
    required this.spanId,
    required this.parent,
    required this.name,
    required this.attributes,
  });

  void start() {
    try {
      if (_startTimestamp == null) {
        if (tracer.enableDartTimeline) {
          _timelineTask = TimelineTask(parent: parent?._timelineTask);
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
      resolve<LogService?>()
          ?.error('Could not start span.', error: e, trace: stack);
    }
  }

  void addEvent(String name, {Map<String, dynamic>? arguments}) {
    _addEvent(Event(
      name: name,
      arguments: arguments ?? <String, dynamic>{},
      timestamp: DateTime.timestamp(),
    ));
  }

  void addExceptionEvent(dynamic error) {
    _addEvent(ExceptionEvent(
      error: error,
      timestamp: DateTime.timestamp(),
    ));
  }

  void _addEvent(Event event) {
    try {
      _events.add(event);
      if (_timelineTask != null) {
        TimelineTask(parent: _timelineTask).instant(
          event.name,
          arguments: {
            'traceId': traceId.hexId,
            'spanId': spanId.hexId,
            ...event.arguments
          },
        );
      }
    } catch (e, stack) {
      resolve<LogService?>()
          ?.error('Could not add trace event.', error: e, trace: stack);
    }
  }

  void stop() {
    if (_endTimestamp == null) {
      _timelineTask?.finish();
      _endTimestamp = DateTime.timestamp();
    }
  }
}
