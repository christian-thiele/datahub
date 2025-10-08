import 'log_level.dart';

class LogMessage {
  final DateTime timestamp;
  final String line;
  final LogLevel level;
  final dynamic error;
  final StackTrace? stack;

  LogMessage({
    required this.timestamp,
    required this.line,
    required this.level,
    this.error,
    this.stack,
  });
}
