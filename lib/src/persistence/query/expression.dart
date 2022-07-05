import 'package:cl_datahub/cl_datahub.dart';

/// Represents an expression that is either static or evaluated
/// for every individual dataset and evaluates into a value.
///
/// See:  [ValueExpression]
///       [DataField]
abstract class Expression {
  const Expression();

  /// This factory constructor checks if the value is an expression itself
  /// or returns a [ValueExpression] that wraps the given value otherwise.
  factory Expression.dynamic(dynamic expression) {
    if (expression is Expression) {
      return expression;
    } else {
      return ValueExpression(expression);
    }
  }

  /// Convenience method for creating a CompareFilter which matches
  /// if this equals [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter equals(dynamic other) =>
      CompareFilter(this, CompareType.equals, Expression.dynamic(other));

  /// Convenience method for creating a CompareFilter which matches
  /// if this does not equal [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter notEquals(dynamic other) =>
      CompareFilter(this, CompareType.notEquals, Expression.dynamic(other));

  Sort asc() => ExpressionSort(this, true);

  Sort desc() => ExpressionSort(this, false);
}

class ValueExpression extends Expression {
  final dynamic value;

  const ValueExpression(this.value);

  @override
  bool operator ==(Object other) =>
      other is ValueExpression && value == other.value;
}

@deprecated
class CustomSqlExpression extends Expression {
  final String sqlExpression;

  const CustomSqlExpression(this.sqlExpression);
}
