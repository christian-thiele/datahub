class MirrorException implements Exception {
  final String message;

  MirrorException(this.message);

  MirrorException.invalidType(Type t) : this('Invalid field type: $t');

  @override
  String toString() => 'MirrorException: $message';
}
