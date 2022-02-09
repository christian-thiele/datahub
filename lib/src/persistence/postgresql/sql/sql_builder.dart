import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
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
    } else if (filter is PropertyCompare) {
      // for case Contains, case insensitivity is solved by using ILIKE,
      // no need for LOWER
      if (filter.caseSensitive || filter.type == PropertyCompareType.Contains) {
        buffer.write(escapeName(filter.propertyName));
      } else {
        buffer.write('LOWER(${escapeName(filter.propertyName)})');
      }
      switch (filter.type) {
        case PropertyCompareType.Contains:
          buffer.write(filter.caseSensitive ? ' LIKE ' : ' ILIKE ');
          break;
        case PropertyCompareType.Equals:
          buffer.write(' = ');
          break;
        case PropertyCompareType.GreaterThan:
          buffer.write(' > ');
          break;
        case PropertyCompareType.LessThan:
          buffer.write(' < ');
          break;
        case PropertyCompareType.GreaterOrEqual:
          buffer.write(' >= ');
          break;
        case PropertyCompareType.LessOrEqual:
          buffer.write(' <= ');
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
        case PropertyCompareType.Contains:
          // case insensitivity is solved by using ILIKE instead of LIKE,
          // no need for LOWER here
          buffer.write(escapeValueLike(filter.value));
          break;
        default:
          if (filter.caseSensitive) {
            buffer.write(escapeValue(filter.value));
          } else {
            buffer.write(escapeValue(filter.value).toLowerCase());
          }
          break;
      }
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
    final sql = propertySorts
        .map((e) =>
            '${escapeName(e.propertyName)} ${e.ascending ? 'ASC' : 'DESC'}')
        .join(', ');
    return Tuple(sql, const {});
  }

  static Tuple<String, Map<String, dynamic>> selectSql(QuerySelect select) {
    if (select is WildcardSelect) {
      return const Tuple('*', {});
    } else if (select is FieldSelect) {
      return Tuple(escapeName(select.field.name), const {});
    } else if (select is AggregateSelect) {
      if (select.type != AggregateType.count && select.select == null) {
        throw PersistenceException(
            'AggregateSelect of type ${select.type} requires an inner select.');
      }

      switch (select.type) {
        case AggregateType.count:
          return Tuple('COUNT(*)', const {});
        case AggregateType.min:
          // dereference safe because of exception above
          final inner = selectSql(select.select!);
          return Tuple('MIN(${inner.a})', inner.b);
        case AggregateType.max:
          // dereference safe because of exception above
          final inner = selectSql(select.select!);
          return Tuple('MAX(${inner.a})', inner.b);
        case AggregateType.sum:
          // dereference safe because of exception above
          final inner = selectSql(select.select!);
          return Tuple('SUM(${inner.a})', inner.b);
        case AggregateType.avg:
          // dereference safe because of exception above
          final inner = selectSql(select.select!);
          return Tuple('AVG(${inner.a})', inner.b);
      }
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
      default:
        throw PersistenceException(
            'PostgreSQL implementation does not support data type ${field.type}.');
    }
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

    return '\'${value.toString().replaceAll('\'', '\'\'')}\''; //TODO other escape things
  }

  static String escapeValueLike(dynamic value) {
    if (value is DateTime) {
      // weird but who knows what kind of use case this has
      // i would expect it to work like that...
      return '\'%${value.toIso8601String()}%\'';
    }

    return '\'%${value.toString().replaceAll('\'', '\'\'')}%\''; //TODO other escape things
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
    }else{
      return '@${e.b}';
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
