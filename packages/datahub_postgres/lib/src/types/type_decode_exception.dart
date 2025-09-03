class TypeDecodeException implements Exception {
  final String message;

  TypeDecodeException(this.message);

  TypeDecodeException.typeMismatch(Type expected, Type actual)
      : this('Cannot decode $expected from value of type "$actual".');
}