import 'dart:convert';

import 'package:datahub/data.dart';

import '../trace/span.dart';
import 'severity_level.dart';

class LogMessage({
  required final DateTime timestamp,
  required final String line,
  required final SeverityLevel level,
  final Map<String, String> labels = const {},
  final Span? span,
  final dynamic error,
  final StackTrace? stack,
}) {
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
