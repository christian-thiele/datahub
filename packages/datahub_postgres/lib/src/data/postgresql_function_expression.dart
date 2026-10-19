import 'package:datahub/data.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';

class const PostgresqlRawExpression(final Sql sql) extends Expression;

class const PostgresqlCastExpression(
  final Expression expression,
  final PostgresqlDataType type,
) extends Expression;

class const PostgresqlAliasExpression(
  final String name,
  final Expression expression,
) extends Expression;

class const PostgresqlFunctionExpression(
  final String name,
  final List<Expression> arguments, [
  final PostgresqlDataType? returnType,
]) extends Expression;
