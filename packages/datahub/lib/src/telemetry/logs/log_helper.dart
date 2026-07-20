import 'package:datahub/scaffold.dart';

import '../telemetry_service.dart';
import 'log_message.dart';
import 'severity_level.dart';

const LogHelper log = LogHelper._();

final class LogHelper {
  const LogHelper._();

  void call(
    String line, {
    SeverityLevel level = SeverityLevel.debug,
    dynamic error,
    StackTrace? stack,
    Map<String, String> labels = const {},
  }) {
    if (Context.maybeOfZone() case final context?) {
      final telemetry = context.find(Find<Telemetry>());
      telemetry.publishLog(
        LogMessage(
          timestamp: DateTime.timestamp(),
          line: line,
          level: level,
          stack: stack,
          error: error,
          labels: labels,
          span: telemetry.getDefaultTracer().findParentSpan(),
        ),
      );
    } else {
      print(line);
    }
  }

  void trace(
    String line, {
    dynamic error,
    StackTrace? stack,
    Map<String, String> labels = const {},
  }) => call(
    line,
    level: SeverityLevel.trace,
    error: error,
    stack: stack,
    labels: labels,
  );

  void debug(
    String line, {
    dynamic error,
    StackTrace? stack,
    Map<String, String> labels = const {},
  }) => call(
    line,
    level: SeverityLevel.debug,
    error: error,
    stack: stack,
    labels: labels,
  );

  void info(
    String line, {
    dynamic error,
    StackTrace? stack,
    Map<String, String> labels = const {},
  }) => call(
    line,
    level: SeverityLevel.info,
    error: error,
    stack: stack,
    labels: labels,
  );

  void warn(
    String line, {
    dynamic error,
    StackTrace? stack,
    Map<String, String> labels = const {},
  }) => call(
    line,
    level: SeverityLevel.warning,
    error: error,
    stack: stack,
    labels: labels,
  );

  void error(
    String line, {
    dynamic error,
    StackTrace? stack,
    Map<String, String> labels = const {},
  }) => call(
    line,
    level: SeverityLevel.error,
    error: error,
    stack: stack,
    labels: labels,
  );

  void fatal(
    String line, {
    dynamic error,
    StackTrace? stack,
    Map<String, String> labels = const {},
  }) => call(
    line,
    level: SeverityLevel.fatal,
    error: error,
    stack: stack,
    labels: labels,
  );
}
