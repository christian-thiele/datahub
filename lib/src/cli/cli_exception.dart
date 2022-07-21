class CliException implements Exception {
  final String message;

  CliException(this.message);

  @override
  String toString() => message;
}
