import 'data_field.dart';

sealed class Expression {
  const Expression();

  factory Expression.dynamic(dynamic candidate) {
    return switch (candidate) {
      Expression() => candidate,
      _ => ValueExpression(candidate),
    };
  }
}

class FieldExpression extends Expression {
  final DataField field;

  const FieldExpression(this.field);
}

class ValueExpression extends Expression {
  final dynamic value;

  const ValueExpression(this.value);
}
