import 'expression.dart';

enum AggregateType { count, sum, max, min, avg }

class AggregateExpression extends Expression {
  final AggregateType type;
  final Expression value;

  const AggregateExpression(this.type, this.value);

  const AggregateExpression.count([Expression? value])
    : this(AggregateType.count, value ?? const ValueExpression(true));

  const AggregateExpression.sum(Expression value)
    : this(AggregateType.sum, value);

  const AggregateExpression.max(Expression value)
    : this(AggregateType.max, value);

  const AggregateExpression.min(Expression value)
    : this(AggregateType.min, value);

  const AggregateExpression.avg(Expression value)
    : this(AggregateType.avg, value);
}

extension AggregateExpressionExtension on Expression {
  AggregateExpression count() => AggregateExpression.count(this);

  AggregateExpression sum() => AggregateExpression.sum(this);

  AggregateExpression max() => AggregateExpression.max(this);

  AggregateExpression min() => AggregateExpression.min(this);

  AggregateExpression avg() => AggregateExpression.avg(this);
}
