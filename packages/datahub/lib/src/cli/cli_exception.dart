class CliException(final String message) implements Exception {
  @override
  String toString() => message;
}
