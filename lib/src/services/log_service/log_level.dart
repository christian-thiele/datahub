enum LogLevel {
  debug(0),
  verbose(1),
  info(2),
  warning(3),
  error(4),
  critical(5);

  final int level;

  const LogLevel(this.level);
}