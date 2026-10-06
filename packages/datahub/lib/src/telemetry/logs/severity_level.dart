import '../../data/data_enum.dart';

/// Severity of a log message, with the severity numbers and short names of
/// the OpenTelemetry log data model.
///
/// [jsonValue] (e.g. `warn`) is used in config values (`telemetry.logLevel`)
/// and in stored log messages, [severityText] (e.g. `WARN`) in log output.
enum SeverityLevel implements DataEnum {
  trace(1, 'trace'),
  debug(5, 'debug'),
  info(9, 'info'),
  warning(13, 'warn'),
  error(17, 'error'),
  fatal(21, 'fatal');

  final int severityNumber;

  @override
  final String jsonValue;

  const SeverityLevel(this.severityNumber, this.jsonValue);

  /// The OpenTelemetry short name, e.g. `WARN`.
  String get severityText => jsonValue.toUpperCase();

  static SeverityLevel ofSeverityNumber(int severityNumber) {
    for (final level in values) {
      if (severityNumber >= level.severityNumber &&
          severityNumber < level.severityNumber + 4) {
        return level;
      }
    }

    return fatal;
  }
}
