import 'package:datahub/data.dart';

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

class UnsupportedExpressionError extends ApiError {
  final Expression expression;

  UnsupportedExpressionError(this.expression, {String? library})
    : super(
        library != null
            ? 'Expression of type ${expression.runtimeType} can not be interpreted by $library.'
            : 'Expression of type ${expression.runtimeType} can not be interpreted.',
      );
}
