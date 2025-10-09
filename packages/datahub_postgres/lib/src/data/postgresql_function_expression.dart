import 'package:datahub/data.dart';
import 'package:datahub_postgres/types.dart';

class PostgresqlFunctionExpression extends Expression {
  final String name;
  final PostgresqlDataType? returnType;
  final List<Expression> arguments;

  const PostgresqlFunctionExpression(
    this.name,
    this.arguments, [
    this.returnType,
  ]);
}
