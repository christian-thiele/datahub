/// Base exception for when things go wrong at runtime inside the
/// DataHub API framework.
class const ApiException(final String message, [final dynamic internal])
    implements Exception {
  @override
  String toString() {
    final buffer = StringBuffer(message);
    if (internal != null) {
      buffer.write('\nInternal exception:\n${internal.toString()}');
    }

    return buffer.toString();
  }
}
