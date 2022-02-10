import 'log_message.dart';

/// Backend interface for [LogService].
///
/// see:
///   [ConsoleLogBackend]
abstract class LogBackend {
  Future<void> initialize() => Future.value();
  void publish(LogMessage message);
}
