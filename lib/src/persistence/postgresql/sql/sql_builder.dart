import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/postgresql.dart';

import 'package:postgres/postgres.dart';

import '../type_registry.dart';

abstract class SqlBuilder {
  /// Returns the sql string together with it's substitution values
  Tuple<String, Map<String, dynamic>> buildSql();

  static Tuple<String, Map<String, dynamic>> filterSql(Filter filter) {
    final buffer = StringBuffer();
    final values = <String, dynamic>{};

    if (filter is FilterGroup) {
      final results = filter.filters.map((e) => filterSql(e));
      //TODO think about how to make substitution values unique
      values.addEntries(results.expand((e) => e.b.entries));

      switch (filter.type) {
        case FilterGroupType.And:
          buffer.write(results.map((e) => '(${e.a})').join(' AND '));
          break;
        case FilterGroupType.Or:
          buffer.write(results.map((e) => '(${e.a})').join(' OR '));
          break;
      }
    } else if (filter is CompareFilter) {
      // special case: isIn empty list (produces error, always false anyway)
      if (filter.type == CompareType.isIn &&
          filter.right is ValueExpression &&
          (filter.right as ValueExpression).value is Iterable &&
          ((filter.right as ValueExpression).value as Iterable).isEmpty) {
        return Tuple('FALSE', {});
      }

      // for case Contains, case insensitivity is solved by using ILIKE,
      // no need for LOWER
      if (filter.caseSensitive ||
          filter.type == CompareType.contains ||
          filter.right == ValueExpression(null)) {
        final result = expressionSql(filter.left).sqlTuple();
        ;
        buffer.write(result.a);
        values.addAll(result.b);
      } else {
        final result = expressionSql(filter.left).sqlTuple();
        ;
        buffer.write('LOWER(${result.a})');
        values.addAll(result.b);
      }

      switch (filter.type) {
        case CompareType.contains:
          buffer.write(filter.caseSensitive ? ' LIKE ' : ' ILIKE ');
          break;
        case CompareType.equals:
          // special cases when checking null
          if (filter.right == ValueExpression(null)) {
            buffer.write(' IS ');
          } else {
            buffer.write(' = ');
          }
          break;
        case CompareType.notEquals:
          // special cases when checking null
          if (filter.right == ValueExpression(null)) {
            buffer.write(' IS NOT ');
          } else {
            buffer.write(' <> ');
          }
          break;
        case CompareType.greaterThan:
          buffer.write(' > ');
          break;
        case CompareType.lessThan:
          buffer.write(' < ');
          break;
        case CompareType.greaterOrEqual:
          buffer.write(' >= ');
          break;
        case CompareType.lessOrEqual:
          buffer.write(' <= ');
          break;
        case CompareType.isIn:
          buffer.write(' IN ');
          break;
        default:
          throw PersistenceException(
              'PropertyCompareType not implemented: ${filter.type}');
      }

      // TODO while we escape values, we don't need to worry about substitution values
      // TODO but that's probably not the best way, lets think of some sort of system that
      // TODO let's us use substitutions without clashing names
      // @CTH by CTH: maybe provide a "namespace" to methods like this to avoid
      // clashing names?
      switch (filter.type) {
        case CompareType.contains:
          // case insensitivity is solved by using ILIKE instead of LIKE,
          // no need for LOWER here
          final result = escapeValueLike(filter.right);
          buffer.write(result.a);
          values.addAll(result.b);
          break;
        default:
          if (filter.caseSensitive ||
              filter.right == const ValueExpression(null)) {
            final result = expressionSql(filter.right).sqlTuple();
            ;
            buffer.write(result.a);
            values.addAll(result.b);
          } else {
            final result = expressionSql(filter.right).sqlTuple();
            ;
            buffer.write('LOWER(${result.a})');
            values.addAll(result.b);
          }
          break;
      }
      // ignore: deprecated_member_use_from_same_package
    } else if (filter is CustomSqlCondition) {
      buffer.write(filter.sql);
    } else {
      throw PersistenceException('PostgreSQL implementation does not '
          'support filter type ${filter.runtimeType}.');
    }

    return Tuple(buffer.toString(), values);
  }

  static Tuple<String, Map<String, dynamic>> sortSql(Sort sort) {
    final propertySorts = sort.linear();
    final result = propertySorts.map((e) {
      final result = expressionSql(e.expression).sqlTuple();
      ;
      return Tuple('${result.a} ${e.ascending ? 'ASC' : 'DESC'}', result.b);
    }).toList();
    return Tuple(result.a.join(', '),
        Map.fromEntries(result.b.expand((e) => e.entries)));
  }

  static Tuple<String, Map<String, dynamic>> selectSql(QuerySelect select) {
    if (select is WildcardSelect) {
      if (select.bean != null) {
        return (escapeName(select.bean!.layoutName) + '.*').sqlTuple();
      } else {
        return '*'.sqlTuple();
      }
    } else if (select is DataField) {
      return fieldSql(select).sqlTuple();
    } else if (select is FieldSelect) {
      if (select.alias != null) {
        return '${fieldSql(select.field)} AS ${escapeName(select.alias!)}'
            .sqlTuple();
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
          return 'COUNT(*) AS ${escapeName(select.alias)}'.sqlTuple();
        case AggregateType.min:
          // dereference safe because of exception above
          final inner = expressionSql(select.expression!).sqlTuple();
          return Tuple(
              'MIN(${inner.a}) AS ${escapeName(select.alias)}', inner.b);
        case AggregateType.max:
          // dereference safe because of exception above
          final inner = expressionSql(select.expression!).sqlTuple();
          return Tuple(
              'MAX(${inner.a}) AS ${escapeName(select.alias)}', inner.b);
        case AggregateType.sum:
          // dereference safe because of exception above
          final inner = expressionSql(select.expression!).sqlTuple();
          return Tuple(
              'SUM(${inner.a}) AS ${escapeName(select.alias)}', inner.b);
        case AggregateType.avg:
          // dereference safe because of exception above
          final inner = expressionSql(select.expression!).sqlTuple();
          return Tuple(
              'AVG(${inner.a}) AS ${escapeName(select.alias)}', inner.b);
      }
    } else if (select is ExpressionSelect) {
      final expression = expressionSql(select.expression).sqlTuple();
      return Tuple(
          '${expression.a} AS ${escapeName(select.alias)}', expression.b);
    } else {
      throw PersistenceException('PostgreSQL implementation does not '
          'support aggregate type ${select.runtimeType}.');
    }
  }

  static String fieldSql(DataField field) {
    return '${escapeName(field.layoutName)}.${escapeName(field.name)}';
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

  @deprecated
  static Tuple<String, Map<String, dynamic>> escapeValueLike(Expression value) {
    if (value is ValueExpression) {
      if (value.value is DateTime) {
        // weird but who knows what kind of use case this has
        // i would expect it to work like that...
        return Tuple('\'%${value.value.toIso8601String()}%\'', {});
      } else {
        return Tuple('\'%${value.value.toString().replaceAll('\'', '\'\'')}%\'',
            {}); //TODO other escape things
      }
    }

    return expressionSql(value).sqlTuple();
  }

  static String expressionSql(Expression expression) {
    if (expression is DataField) {
      return fieldSql(expression);
    } else if (expression is ValueExpression) {
      return escapeValue(expression.value);
      // ignore: deprecated_member_use_from_same_package
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

      return '($left $operator $right)';
    } else if (expression is CustomSqlExpression) {
      return expression.sqlExpression;
    } else {
      throw PersistenceException('PostgreSQL implementation does not '
          'support Expression type ${expression.runtimeType}.');
    }
  }

  @deprecated
  static dynamic toSqlData(dynamic value) {
    if (value is Point) {
      return PgPoint(value.x, value.y);
    }

    // Postges lib does not support Uint8List yet... :(
    // in SqlBuilder.substitutionLiteral this is then decoded again
    if (value is Uint8List) {
      return value.toHexString();
    }

    if (value is List || value is Map<String, dynamic>) {
      return jsonEncode(value);
    }

    return value;
  }
}

class RawSql implements SqlBuilder {
  final String rawSql;
  final Map<String, dynamic> substitutionValues;

  RawSql(this.rawSql, [this.substitutionValues = const {}]);

  @override
  Tuple<String, Map<String, dynamic>> buildSql() =>
      Tuple(rawSql, substitutionValues);
}

extension _SqlTuple on String {
  Tuple<String, Map<String, dynamic>> sqlTuple() => Tuple(this, const {});
}
