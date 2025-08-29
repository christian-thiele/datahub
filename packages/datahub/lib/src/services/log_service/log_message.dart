import 'log_level.dart';

class LogMessage {
  final DateTime timestamp;
  final String? sender;
  final String message;
  final LogLevel level;
  final dynamic exception;
  final StackTrace? trace;
  final Map<String, dynamic> meta;

  LogMessage(
    this.timestamp,
    this.sender,
    this.message,
    this.level,
    this.exception,
    this.trace,
    this.meta,
  );
}
