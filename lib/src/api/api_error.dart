class ApiError extends Error {
  final String message;

  ApiError(this.message);

  ApiError.invalidType(Type t) : this('Invalid type: $t');

  @override
  String toString() => message;
}