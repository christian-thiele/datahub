import 'package:datahub/data.dart';
import 'package:datahub_postgres/schema.dart';
import 'sql.dart';

class SqlFilter {
  final Filter filter;

  SqlFilter(this.filter);

  Sql toSql() {
    switch (filter) {
      case FilterGroup(:final filters, :final isConjunction):
        return filters
            .map((e) => SqlFilter(e).toSql()..wrap())
            .joinSql(isConjunction ? ' AND ' : ' OR ');
      case final CompareFilter filter:
        final sql = Sql('');
        // special case: isIn empty list / null (always false)
        if (filter.type == CompareType.isIn &&
            (filter.right is ValueExpression &&
                    (filter.right as ValueExpression).value is Iterable &&
                    ((filter.right as ValueExpression).value as Iterable)
                        .isEmpty ||
                filter.right == ValueExpression(null))) {
          return Sql('FALSE');
        }

        // for case Contains, case insensitivity is solved by using ILIKE,
        // no need for LOWER
        if (filter.caseSensitive ||
            filter.type == CompareType.contains ||
            filter.right == ValueExpression(null)) {
          sql.add(expressionSql(filter.left));
        } else {
          sql.addSql('LOWER');
          sql.add(expressionSql(filter.left)..wrap());
        }

        switch (filter.type) {
          case CompareType.contains:
            sql.addSql(filter.caseSensitive ? ' LIKE ' : ' ILIKE ');
            break;
          case CompareType.equals:
            // special cases when checking null
            if (filter.right == ValueExpression(null)) {
              sql.addSql(' IS ');
            } else {
              sql.addSql(' = ');
            }
            break;
          case CompareType.notEquals:
            // special cases when checking null
            if (filter.right == ValueExpression(null)) {
              sql.addSql(' IS NOT ');
            } else {
              sql.addSql(' <> ');
            }
            break;
          case CompareType.greaterThan:
            sql.addSql(' > ');
            break;
          case CompareType.lessThan:
            sql.addSql(' < ');
            break;
          case CompareType.greaterOrEqual:
            sql.addSql(' >= ');
            break;
          case CompareType.lessOrEqual:
            sql.addSql(' <= ');
            break;
          case CompareType.isIn:
            sql.addSql(' = ');
            break;
        }

        switch (filter.type) {
          case CompareType.contains:
            // case insensitivity is solved by using ILIKE instead of LIKE,
            // no need for LOWER here
            sql.add(Sql("'%' || "));
            sql.add(expressionSql(filter.right));
            sql.add(Sql(" || '%'"));
            break;
          case CompareType.isIn:
            throw UnimplementedError();
          // TODO fix this
          /*
            sql.addSql('ANY(');
            if (filter.right is ValueExpression &&
                (filter.right as ValueExpression).value is List) {
              final list = (filter.right as ValueExpression).value as List;
              final sanitized =
                  list.map((e) => e is Enum ? e.name : e).toList();
              sql.addParam(sanitized, PostgreSQLDataType.unknownType);
            } else {
              sql.add(expressionSql(filter.right));
            }
            sql.addSql(')');
             */
          default:
            if (filter.caseSensitive ||
                filter.right == const ValueExpression(null)) {
              sql.add(expressionSql(filter.right));
            } else {
              sql.addSql('LOWER');
              sql.add(expressionSql(filter.right)..wrap());
            }
            break;
        }
        return sql;
      case _:
        throw Exception('PostgreSQL implementation does not '
            'support filter type ${filter.runtimeType}.');
    }
  }

  Sql expressionSql(Expression expression) {
    if (expression case FieldExpression(:final field)) {
      return Sql(Sql.escapeName(field.name));
    } else if (expression case ValueExpression(:final value)) {
      return switch (value) {
        Enum(:final name) => Sql.param(name, PostgresqlDataType.varChar),
        String() => Sql.param(value, PostgresqlDataType.text),
        int() => Sql.param(value, PostgresqlDataType.bigInt),
        double() => Sql.param(value, PostgresqlDataType.doublePrecision),
        bool() => Sql.param(value, PostgresqlDataType.boolean),
        DateTime() => Sql.param(value, PostgresqlDataType.timestamp),
        null => Sql('NULL'),
        //TODO fix this all
        _ => throw UnimplementedError(),
        //_ => findTypeForValue(expression.value)
        //    .toPostgresValue(null, expression.value),
      };

      /* else if (expression is OperationExpression) {

      late String operator;
      switch (expression.type) {
        case OperationType.add:
          operator = '+';
          break;
        case OperationType.subtract:
          operator = '-';
          break;
        case OperationType.multiply:
          operator = '*';
          break;
        case OperationType.divide:
          operator = '/';
          break;
        default:
          throw Exception('PostgreSQL implementation does not '
              'support OperationExpression type ${expression.type}.');
      }
      final left = expressionSql(expression.left);
      final right = expressionSql(expression.right);

      final sql = Sql('(');
      sql.add(left);
      sql.addSql(' $operator ');
      sql.add(right);
      sql.addSql(')');
      return sql;
      // ignore: deprecated_member_use
    } else if (expression is FunctionExpression) {
      final sql = Sql(expression.name);
      sql.add(expression.arguments.map(expressionSql).joinSql(', ')..wrap());
      return sql;
    } else if (expression is SqlExpression) {
      return expression.clone();
    } else if (expression is CustomOperatorExpression) {
      final sql = expressionSql(expression.left);
      sql.add(SqlExpression(expression.operatorSql));
      sql.add(expressionSql(expression.right));
      return sql;*/
    } else {
      throw Exception('PostgreSQL implementation does not '
          'support Expression type ${expression.runtimeType}.');
    }
  }
}
