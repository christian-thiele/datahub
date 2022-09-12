class ResourceTransportException implements Exception {
  final String message;

  ResourceTransportException(this.message);

  @override
  String toString() => message;
}
