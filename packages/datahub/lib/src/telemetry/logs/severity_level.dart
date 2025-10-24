enum SeverityLevel {
  trace(1),
  debug(5),
  info(9),
  warning(13),
  error(17),
  fatal(21);

  final int severityNumber;

  const SeverityLevel(this.severityNumber);

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
