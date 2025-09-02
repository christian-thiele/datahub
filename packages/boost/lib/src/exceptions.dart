/// Base class for boost exceptions.
class BoostException implements Exception {
  final dynamic message;
  final Exception? cause;

  BoostException([this.message, this.cause]) : super();

  @override
  String toString() {
    final buffer = StringBuffer('$message\n');
    if (cause != null) {
      buffer.write('Cause:\n${cause.toString()}');
    }
    return buffer.toString();
  }
}
