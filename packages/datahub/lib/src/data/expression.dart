abstract class Expression {
  const Expression();

  factory Expression.dynamic(dynamic candidate) {
    return switch (candidate) {
      Expression() => candidate,
      _ => ValueExpression(candidate),
    };
  }
}

class ValueExpression extends Expression {
  final dynamic value;

  const ValueExpression(this.value);
}
