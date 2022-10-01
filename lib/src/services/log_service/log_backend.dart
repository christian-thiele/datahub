import 'log_message.dart';

/// Backend interface for [LogService].
///
/// see:
///   [ConsoleLogBackend]
abstract class LogBackend {
  Future<void> initialize() async {}
  Future<void> shutdown() async {}

  void publish(LogMessage message);
  void setLogLevel(int level);
}
