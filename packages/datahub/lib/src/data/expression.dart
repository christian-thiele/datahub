abstract class const Expression() {
  factory dynamic(dynamic candidate) {
    return switch (candidate) {
      Expression() => candidate,
      _ => ValueExpression(candidate),
    };
  }
}

class const ValueExpression(final dynamic value) extends Expression;
