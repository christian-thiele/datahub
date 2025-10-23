import 'log_level.dart';

import '../trace/span.dart';

class LogMessage {
  final DateTime timestamp;
  final String line;
  final SeverityLevel level;
  final Span? span;
  final dynamic error;
  final StackTrace? stack;

  LogMessage({
    required this.timestamp,
    required this.line,
    required this.level,
    this.span,
    this.error,
    this.stack,
  });
}
