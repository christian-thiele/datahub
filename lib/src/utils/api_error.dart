/// Base error for when DataHub code APIs are used incorrectly by user code.
///
/// If this error is thrown, you did something wrong in your code!
/// At best an API Error explains the problem and suggests a solution.
class ApiError extends Error {
  final String message;

  ApiError(this.message);

  ApiError.invalidType(Type t) : this('Invalid type: $t');

  @override
  String toString() => message;
}
