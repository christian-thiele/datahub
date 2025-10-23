import 'package:datahub/scaffold.dart';
import 'package:datahub/src/telemetry/logs/log_level.dart';
import 'package:datahub/src/telemetry/logs/log_message.dart';
import 'package:datahub/src/telemetry/telemetry_service.dart';

const LogHelper log = LogHelper._();

final class LogHelper {
  const LogHelper._();

  void call(
    String line, {
    SeverityLevel level = SeverityLevel.debug,
    dynamic error,
    StackTrace? stack,
  }) {
    if (Context.maybeOfZone() case final context?) {
      context
          .find(Find<Telemetry>())
          .publishLog(
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

  void trace(String line, {dynamic error, StackTrace? stack}) =>
      call(line, level: SeverityLevel.trace, error: error, stack: stack);

  void debug(String line, {dynamic error, StackTrace? stack}) =>
      call(line, level: SeverityLevel.debug, error: error, stack: stack);

  void info(String line, {dynamic error, StackTrace? stack}) =>
      call(line, level: SeverityLevel.info, error: error, stack: stack);

  void warn(String line, {dynamic error, StackTrace? stack}) =>
      call(line, level: SeverityLevel.warning, error: error, stack: stack);

  void error(String line, {dynamic error, StackTrace? stack}) =>
      call(line, level: SeverityLevel.error, error: error, stack: stack);

  void fatal(String line, {dynamic error, StackTrace? stack}) =>
      call(line, level: SeverityLevel.fatal, error: error, stack: stack);
}
