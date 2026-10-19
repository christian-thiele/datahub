class TypeDecodeException(final String message) implements Exception {
  new typeMismatch(Type expected, Type actual)
    : this('Cannot decode $expected from value of type "$actual".');
}
