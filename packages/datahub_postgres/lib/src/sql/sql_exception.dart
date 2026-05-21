class SqlException implements Exception {
  final String message;

  SqlException(this.message);

  @override
  String toString() => message;
}
