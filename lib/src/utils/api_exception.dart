/// Base exception for when things go wrong at runtime inside the
/// DataHub API framework.
class ApiException implements Exception {
  final Exception? internal;
  final String message;

  ApiException(this.message, [this.internal]);

  @override
  String toString() {
    final buffer = StringBuffer(message);
    if (internal != null) {
      buffer.write('\nInternal exception:\n${internal.toString()}');
    }

    return buffer.toString();
  }
}
