import 'data_field.dart';

sealed class Expression {
  const Expression();

  factory Expression.dynamic(dynamic candidate) {
    return switch (candidate) {
      DataField() => FieldExpression(candidate),
      _ => ValueExpression(candidate),
    };
  }
}

final class FieldExpression extends Expression {
  final DataField field;

  const FieldExpression(this.field);
}

final class ValueExpression extends Expression {
  final dynamic value;

  const ValueExpression(this.value);
}
