import 'package:datahub/data.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';

class PostgresqlRawExpression extends Expression {
  final Sql sql;

  const PostgresqlRawExpression(this.sql);
}

class PostgresqlCastExpression extends Expression {
  final Expression expression;
  final PostgresqlDataType type;

  const PostgresqlCastExpression(this.expression, this.type);
}

class PostgresqlAliasExpression extends Expression {
  final String name;
  final Expression expression;

  const PostgresqlAliasExpression(this.name, this.expression);
}

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
