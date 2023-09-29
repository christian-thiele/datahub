import 'package:datahub/persistence.dart';

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

  /// Convenience method for creating a CompareFilter which matches
  /// if this is greater than [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter greaterThan(dynamic other) =>
      CompareFilter(this, CompareType.greaterThan, Expression.dynamic(other));

  /// Convenience method for creating a CompareFilter which matches
  /// if this is greater than or equals [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter greaterOrEqual(dynamic other) => CompareFilter(
      this, CompareType.greaterOrEqual, Expression.dynamic(other));

  /// Convenience method for creating a CompareFilter which matches
  /// if this is less than [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter lessThan(dynamic other) =>
      CompareFilter(this, CompareType.lessThan, Expression.dynamic(other));

  /// Convenience method for creating a CompareFilter which matches
  /// if this is less than or equals [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter lessOrEqual(dynamic other) =>
      CompareFilter(this, CompareType.lessOrEqual, Expression.dynamic(other));

  /// Convenience method for creating a CompareFilter which matches
  /// if this contains [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter contains(dynamic other) =>
      CompareFilter(this, CompareType.contains, Expression.dynamic(other));

  /// Convenience method for creating a CompareFilter which matches
  /// if this is in [other].
  ///
  /// If [other] is not an [Expression], it will be wrapped into
  /// a [ValueExpression].
  Filter isIn(dynamic other) =>
      CompareFilter(this, CompareType.isIn, Expression.dynamic(other));

  /// Creates a [Sort] that orders ascending by this expression.
  Sort asc() => sort(true);

  /// Creates a [Sort] that orders descending by this expression.
  Sort desc() => sort(false);

  /// Creates a [Sort] that orders by this expression.
  Sort sort(bool ascending) => ExpressionSort(this, ascending);
}

class ValueExpression extends Expression {
  final dynamic value;

  const ValueExpression(this.value);

  @override
  bool operator ==(Object other) =>
      other is ValueExpression && value == other.value;
}

class OperationExpression extends Expression {
  final Expression left;
  final Expression right;
  final OperationType type;

  OperationExpression(this.left, this.right, this.type);
}

enum OperationType { add, subtract, multiply, divide }

@deprecated
class CustomSqlExpression extends Expression {
  final String sqlExpression;

  const CustomSqlExpression(this.sqlExpression);
}
