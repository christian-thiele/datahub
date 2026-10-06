import 'log_message.dart';

/// Receives the log messages that pass the configured log level.
abstract class LogExporter {
  void add(LogMessage message);

  Future<void> initialize() async {}

  Future<void> shutdown() async {}
}
