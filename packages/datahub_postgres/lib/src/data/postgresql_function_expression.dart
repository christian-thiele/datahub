import 'package:datahub/data.dart';
import 'package:datahub_postgres/types.dart';
import 'package:datahub_postgres/sql.dart';

class PostgresqlRawExpression extends Expression {
  final Sql sql;

  const PostgresqlRawExpression(this.sql);
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
