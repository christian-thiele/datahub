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
}
