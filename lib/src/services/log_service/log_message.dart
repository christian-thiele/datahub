class LogMessage {
  static const debug = 0;
  static const verbose = 1;
  static const info = 2;
  static const warning = 3;
  static const error = 4;
  static const critical = 5;

  final DateTime timestamp;
  final String? sender;
  final String message;
  final int severity;
  final dynamic exception;
  final StackTrace? trace;

  LogMessage(
    this.timestamp,
    this.sender,
    this.message,
    this.severity,
    this.exception,
    this.trace,
  );
}
