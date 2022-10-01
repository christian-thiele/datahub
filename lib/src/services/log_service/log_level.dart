enum LogLevel { debug, verbose, info, warning, error, critical }

extension SeverityLogLevelExtension on LogLevel {
  int toSeverity() {
    switch (this) {
      case LogLevel.debug:
        return 0;
      case LogLevel.verbose:
        return 1;
      case LogLevel.info:
        return 2;
      case LogLevel.warning:
        return 3;
      case LogLevel.error:
        return 4;
      case LogLevel.critical:
        return 5;
    }
  }
}
