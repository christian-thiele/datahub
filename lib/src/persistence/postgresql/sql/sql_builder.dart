import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:postgres/postgres.dart';

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
      // for case Contains, case insensitivity is solved by using ILIKE,
      // no need for LOWER
      if (filter.caseSensitive ||
          filter.type == CompareType.contains ||
          filter.right == ValueExpression(null)) {
        final result = expressionSql(filter.left);
        buffer.write(result.a);
        values.addAll(result.b);
      } else {
        final result = expressionSql(filter.left);
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
            final result = expressionSql(filter.right);
            buffer.write(result.a);
            values.addAll(result.b);
          } else {
            final result = expressionSql(filter.right);
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
      final result = expressionSql(e.expression);
      return Tuple('${result.a} ${e.ascending ? 'ASC' : 'DESC'}', result.b);
    }).toList();
    return Tuple(result.a.join(', '),
        Map.fromEntries(result.b.expand((e) => e.entries)));
  }

  static Tuple<String, Map<String, dynamic>> selectSql(QuerySelect select) {
    if (select is WildcardSelect) {
      if (select.bean != null) {
        return Tuple(escapeName(select.bean!.layoutName) + '.*', const {});
      } else {
        return const Tuple('*', {});
      }
    } else if (select is DataField) {
      return Tuple(fieldSql(select), const {});
    } else if (select is FieldSelect) {
      if (select.alias != null) {
        return Tuple(
          '${fieldSql(select.field)} AS ${escapeName(select.alias!)}',
          const {},
        );
      } else {
        return selectSql(select.field);
      }
    } else if (select is AggregateSelect) {
      if (select.type != AggregateType.count && select.select == null) {
        throw PersistenceException(
            'AggregateSelect of type ${select.type} requires an inner select.');
      }

      switch (select.type) {
        case AggregateType.count:
          return Tuple('COUNT(*) AS ${escapeName(select.alias)}', const {});
        case AggregateType.min:
          // dereference safe because of exception above
          final inner = selectSql(select.select!);
          return Tuple(
              'MIN(${inner.a}) AS ${escapeName(select.alias)}', inner.b);
        case AggregateType.max:
          // dereference safe because of exception above
          final inner = selectSql(select.select!);
          return Tuple(
              'MAX(${inner.a}) AS ${escapeName(select.alias)}', inner.b);
        case AggregateType.sum:
          // dereference safe because of exception above
          final inner = selectSql(select.select!);
          return Tuple(
              'SUM(${inner.a}) AS ${escapeName(select.alias)}', inner.b);
        case AggregateType.avg:
          // dereference safe because of exception above
          final inner = selectSql(select.select!);
          return Tuple(
              'AVG(${inner.a}) AS ${escapeName(select.alias)}', inner.b);
      }
    } else if (select is ExpressionSelect) {
      return Tuple(
          '${expressionSql(select.expression)} AS ${escapeName(select.alias)}',
          {});
    } else {
      throw PersistenceException('PostgreSQL implementation does not '
          'support aggregate type ${select.runtimeType}.');
    }
  }

  static String typeSql(DataField field) {
    switch (field.type) {
      case FieldType.String:
        return 'varchar(${field.length})';
      case FieldType.Int:
        if (field is PrimaryKey && field.autoIncrement) {
          if (field.length == 32) {
            return 'serial';
          } else if (field.length == 64) {
            return 'bigserial';
          } else {
            throw PersistenceException(
                'PostgreSQL implementation does not support serial length ${field.length}.'
                'Only 16, 32 or 64 allowed.)');
          }
        } else if (field.length == 16) {
          return 'int2';
        } else if (field.length == 32) {
          return 'int4';
        } else if (field.length == 64) {
          return 'int8';
        } else {
          throw PersistenceException(
              'PostgreSQL implementation does not support int length ${field.length}.'
              'Only 16, 32 or 64 allowed.)');
        }
      case FieldType.Float:
        if (field.length == 32) {
          return 'real';
        } else if (field.length == 64) {
          return 'double precision';
        } else {
          throw PersistenceException(
              'PostgreSQL implementation does not support float length ${field.length}.'
              'Only 32 or 64 allowed.)');
        }
      case FieldType.Bool:
        return 'boolean';
      case FieldType.DateTime:
        return 'timestamp with time zone'; //TODO with time zone variable?
      case FieldType.Bytes:
        return 'bytea';
      case FieldType.Point:
        return 'point';
      case FieldType.Json:
        return 'jsonb';
      default:
        throw PersistenceException(
            'PostgreSQL implementation does not support data type ${field.type}.');
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
      return '(${value.map(escapeValue).join(', ')})';
    }

    if (value is Enum) {
      return escapeValue(value.name);
    }

    return '\'${value.toString().replaceAll('\'', '\'\'')}\''; //TODO other escape things
  }

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

    return expressionSql(value);
  }

  /// Returns a substitution literal.
  ///
  /// Triple contains
  /// a: field name
  /// b: field substitution key
  /// c: substituted value
  static String substitutionLiteral(Triple<String, String, dynamic> e) {
    if (e.c is Uint8List) {
      // in SqlBuilder.toSqlData Uint8List objects are converted to hex strings
      return "decode(@${e.b}, 'hex')";
    } else if (e.c is List || e.c is Map<String, dynamic>) {
      return '@${e.b}::jsonb';
    } else {
      return '@${e.b}';
    }
  }

  static Tuple<String, Map<String, dynamic>> expressionSql(
      Expression expression) {
    if (expression is DataField) {
      return Tuple(fieldSql(expression), {});
    } else if (expression is ValueExpression) {
      return Tuple(escapeValue(expression.value), {});
      // ignore: deprecated_member_use_from_same_package
    } else if (expression is CustomSqlExpression) {
      return Tuple(expression.sqlExpression, {});
    } else {
      throw PersistenceException('PostgreSQL implementation does not '
          'support Expression type ${expression.runtimeType}.');
    }
  }

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
