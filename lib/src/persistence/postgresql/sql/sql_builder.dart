import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/src/persistence/persistence_exception.dart';

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
      buffer.write(escapeName(filter.propertyName));
      switch (filter.type) {
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
      }

      // TODO while we escape values, we don't need to worry about substitution values
      // TODO but that's probably not the best way, lets think of some sort of system that
      // TODO let's us use substitutions without clashing names
      buffer.write(escapeValue(filter.value));
    }

    return Tuple(buffer.toString(), values);
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
}

class RawSql implements SqlBuilder {
  final String rawSql;
  final Map<String, dynamic> substitutionValues;

  RawSql(this.rawSql, [this.substitutionValues = const {}]);

  @override
  Tuple<String, Map<String, dynamic>> buildSql() =>
      Tuple(rawSql, substitutionValues);
}
