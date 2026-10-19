import 'package:datahub/data.dart';

/// Base error for when DataHub code APIs are used incorrectly by user code.
///
/// If this error is thrown, you did something wrong in your code!
/// At best an API Error explains the problem and suggests a solution.
class ApiError(final String message) extends Error {
  new invalidType(Type t) : this('Invalid type: $t');

  @override
  String toString() => message;
}

class UnsupportedExpressionError(final Expression expression, {String? library})
    extends ApiError {
  this
    : super(
        library != null
            ? 'Expression of type ${expression.runtimeType} can not be interpreted by $library.'
            : 'Expression of type ${expression.runtimeType} can not be interpreted.',
      );
}
