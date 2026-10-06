import 'dart:convert';

import 'package:datahub/data.dart';

import '../trace/span.dart';
import 'severity_level.dart';

class LogMessage {
  final DateTime timestamp;
  final String line;
  final SeverityLevel level;
  final Span? span;
  final Map<String, String> labels;
  final dynamic error;
  final StackTrace? stack;

  LogMessage({
    required this.timestamp,
    required this.line,
    required this.level,
    this.labels = const {},
    this.span,
    this.error,
    this.stack,
  });

  /// The message as one line of JSON, the format of stored log lines (like the
  /// messages of a workflow step or a scheduled run): the labels, `timestamp`,
  /// `severity`, `msg` and, if present, `error`, `trace_id` and `span_id`.
  String toJsonLine() => jsonEncode({
    ...labels,
    'timestamp': timestamp.toIso8601String(),
    'severity': const JsonDataCodec().encodeEnum(level),
    'msg': line,
    if (error != null) 'error': error.toString(),
    if (span case final span?) ...{
      'trace_id': span.traceId.hexId,
      'span_id': span.spanId.hexId,
    },
  });
}
