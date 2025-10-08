import 'package:datahub/scaffold.dart';
import 'package:datahub/src/telemetry/log_service/log_level.dart';
import 'package:datahub/src/telemetry/log_service/log_message.dart';
import 'package:datahub/src/telemetry/log_service/log_service.dart';

const LogHelper log = LogHelper._();

final class LogHelper {
  const LogHelper._();

  void call(
    String line, {
    LogLevel level = LogLevel.verbose,
    dynamic error,
    StackTrace? stack,
  }) {
    if (Context.maybeOfZone() case final context?) {
      context
          .find(Find<LogReceiver>())
          .publish(
            LogMessage(
              timestamp: DateTime.timestamp(),
              line: line,
              level: level,
              stack: stack,
              error: error,
            ),
          );
    } else {
      print(line);
    }
  }

  void debug(String line, {dynamic error, StackTrace? stack}) =>
      call(line, level: LogLevel.debug, error: error, stack: stack);

  void info(String line, {dynamic error, StackTrace? stack}) =>
      call(line, level: LogLevel.info, error: error, stack: stack);

  void warn(String line, {dynamic error, StackTrace? stack}) =>
      call(line, level: LogLevel.warning, error: error, stack: stack);

  void error(String line, {dynamic error, StackTrace? stack}) =>
      call(line, level: LogLevel.error, error: error, stack: stack);

  void critical(String line, {dynamic error, StackTrace? stack}) =>
      call(line, level: LogLevel.critical, error: error, stack: stack);
}
