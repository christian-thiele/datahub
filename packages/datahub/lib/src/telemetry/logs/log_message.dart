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
