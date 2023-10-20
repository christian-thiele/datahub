import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';

import 'package:postgres/postgres_v3_experimental.dart';

import 'param_sql.dart';

abstract class SqlBuilder {
  /// Returns the sql string together with it's substitution values
  ParamSql buildSql();

  static ParamSql filterSql(Filter filter) {
    final sql = ParamSql('');

    if (filter is FilterGroup) {
      final results = filter.filters.map((e) => filterSql(e)..wrap()).toList();

      switch (filter.type) {
        case FilterGroupType.And:
          sql.add(results.joinSql(' AND '));
          break;
        case FilterGroupType.Or:
          sql.add(results.joinSql(' OR '));
          break;
      }
    } else if (filter is CompareFilter) {
      // special case: isIn empty list (produces error, always false anyway)
      if (filter.type == CompareType.isIn &&
          filter.right is ValueExpression &&
          (filter.right as ValueExpression).value is Iterable &&
          ((filter.right as ValueExpression).value as Iterable).isEmpty) {
        return ParamSql('FALSE');
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
          sql.addSql(' IN ');
          break;
        default:
          throw PersistenceException(
              'PropertyCompareType not implemented: ${filter.type}');
      }

      switch (filter.type) {
        case CompareType.contains:
          // case insensitivity is solved by using ILIKE instead of LIKE,
          // no need for LOWER here
          sql.add(ParamSql("'%' || "));
          sql.add(expressionSql(filter.right));
          sql.add(ParamSql(" || '%'"));
          break;
        default:
          if (filter.caseSensitive ||
              filter.right == const ValueExpression(null)) {
            sql.add(expressionSql(filter.left));
          } else {
            sql.addSql('LOWER');
            sql.add(expressionSql(filter.left)..wrap());
          }
          break;
      }
      // ignore: deprecated_member_use_from_same_package
    } else if (filter is CustomSqlCondition) {
      sql.addSql(filter.sql);
    } else {
      throw PersistenceException('PostgreSQL implementation does not '
          'support filter type ${filter.runtimeType}.');
    }

    return sql;
  }

  static ParamSql sortSql(Sort sort) {
    final propertySorts = sort.linear();
    final results = propertySorts.map((e) {
      final result = expressionSql(e.expression);
      result.addSql(e.ascending ? ' ASC' : ' DESC');
      return result;
    }).toList();
    return results.joinSql(', ');
  }

  static ParamSql selectSql(QuerySelect select) {
    if (select is WildcardSelect) {
      if (select.bean != null) {
        return ParamSql(escapeName(select.bean!.layoutName) + '.*');
      } else {
        return ParamSql('*');
      }
    } else if (select is DataField) {
      return fieldSql(select);
    } else if (select is FieldSelect) {
      if (select.alias != null) {
        return ParamSql(
            '${fieldSql(select.field)} AS ${escapeName(select.alias!)}');
      } else {
        return selectSql(select.field);
      }
    } else if (select is AggregateSelect) {
      if (select.type != AggregateType.count && select.expression == null) {
        throw PersistenceException(
            'AggregateSelect of type ${select.type} requires an inner expression.');
      }

      switch (select.type) {
        case AggregateType.count:
          return ParamSql('COUNT(*) AS ${escapeName(select.alias)}');
        case AggregateType.min:
          final sql = ParamSql('MIN');
          // dereference safe because of exception above
          sql.add(expressionSql(select.expression!)..wrap());
          sql.addSql(' AS ${escapeName(select.alias)}');
          return sql;
        case AggregateType.max:
          final sql = ParamSql('MAX');
          // dereference safe because of exception above
          sql.add(expressionSql(select.expression!)..wrap());
          sql.addSql(' AS ${escapeName(select.alias)}');
          return sql;
        case AggregateType.sum:
          final sql = ParamSql('SUM');
          // dereference safe because of exception above
          sql.add(expressionSql(select.expression!)..wrap());
          sql.addSql(' AS ${escapeName(select.alias)}');
          return sql;
        case AggregateType.avg:
          final sql = ParamSql('AVG');
          // dereference safe because of exception above
          sql.add(expressionSql(select.expression!)..wrap());
          sql.addSql(' AS ${escapeName(select.alias)}');
          return sql;
      }
    } else if (select is ExpressionSelect) {
      final expression = expressionSql(select.expression);
      expression.addSql(' AS ${escapeName(select.alias)}');
      return expression;
    } else {
      throw PersistenceException('PostgreSQL implementation does not '
          'support aggregate type ${select.runtimeType}.');
    }
  }

  static ParamSql fieldSql(DataField field) {
    return ParamSql(
        '${escapeName(field.layoutName)}.${escapeName(field.name)}');
  }

  static String escapeName(String name) {
    if (name.isEmpty || name.length > 128) {
      throw PersistenceException('Field name "$name" has invalid length. '
          '(Must be in range 1 - 128)');
    }

    if (name.contains('"')) {
      //TODO check for more invalid characters
      throw PersistenceException(
          'Field name "$name" contains invalid characters.');
    }

    //TODO check for forbidden names like ANALYZE, BETWEEN, ...

    //TODO check for first letter restriction

    return '"$name"';
  }

  static String escapeValue(dynamic value) {
    if (value == null) {
      return 'NULL';
    }

    if (value is num) {
      return value.toString();
    }

    if (value is bool) {
      return value ? 'true' : 'false';
    }

    if (value is DateTime) {
      return '\'${value.toIso8601String()}\'';
    }

    if (value is Iterable) {
      if (value.isEmpty) {
        throw PersistenceException('Invalid postgres value: (empty list)');
      }
      return '(${value.map(escapeValue).join(', ')})';
    }

    if (value is Enum) {
      return escapeValue(value.name);
    }

    return '\'${value.toString().replaceAll('\'', '\'\'')}\''; //TODO other escape things
  }

  static ParamSql expressionSql(Expression expression) {
    if (expression is DataField) {
      return fieldSql(expression);
    } else if (expression is ValueExpression) {
      return ParamSql.param(
          expression.value, PgDataType.unknownType); //TODO shit...
    } else if (expression is OperationExpression) {
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
          throw PersistenceException('PostgreSQL implementation does not '
              'support OperationExpression type ${expression.type}.');
      }
      final left = expressionSql(expression.left);
      final right = expressionSql(expression.right);

      final sql = ParamSql('(');
      sql.add(left);
      sql.addSql(' $operator ');
      sql.addSql(' ');
      sql.add(right);
      sql.addSql(')');
      return sql;
      // ignore: deprecated_member_use_from_same_package
    } else if (expression is CustomSqlExpression) {
      return ParamSql(expression.sqlExpression);
    } else {
      throw PersistenceException('PostgreSQL implementation does not '
          'support Expression type ${expression.runtimeType}.');
    }
  }
}
