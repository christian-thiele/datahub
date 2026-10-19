import 'expression.dart';

enum AggregateType() {
  count,
  sum,
  max,
  min,
  avg,
}

class const AggregateExpression(
  final AggregateType type,
  final Expression value,
) extends Expression {
  const new count([Expression? value])
    : this(AggregateType.count, value ?? const ValueExpression(true));

  const new sum(Expression value) : this(AggregateType.sum, value);

  const new max(Expression value) : this(AggregateType.max, value);

  const new min(Expression value) : this(AggregateType.min, value);

  const new avg(Expression value) : this(AggregateType.avg, value);
}

extension AggregateExpressionExtension on Expression {
  AggregateExpression count() => AggregateExpression.count(this);

  AggregateExpression sum() => AggregateExpression.sum(this);

  AggregateExpression max() => AggregateExpression.max(this);

  AggregateExpression min() => AggregateExpression.min(this);

  AggregateExpression avg() => AggregateExpression.avg(this);
}
