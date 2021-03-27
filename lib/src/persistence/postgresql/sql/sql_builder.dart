import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/src/persistence/persistence_exception.dart';

abstract class SqlBuilder {
  /// Returns the sql string together with it's substitution values
  Tuple<String, Map<String, dynamic>> buildSql();
}

class RawSql implements SqlBuilder {
  final String rawSql;
  final Map<String, dynamic> substitutionValues;

  RawSql(this.rawSql, [this.substitutionValues = const {}]);

  @override
  Tuple<String, Map<String, dynamic>> buildSql() =>
      Tuple(rawSql, substitutionValues);
}

//TODO complete select
class SelectBuilder implements SqlBuilder {
  final String schemaName;
  final String tableName;
  Filter? _filter;

  SelectBuilder(this.schemaName, this.tableName);

  void where(Filter? filter) {
    _filter = filter;
  }

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final buffer = StringBuffer('SELECT ');
    final values = <String, dynamic>{};

    //TODO columns
    buffer.write('* ');

    buffer.write('FROM $schemaName.$tableName');

    if (_filter != null) {
      buffer.write(' WHERE ');

      final filterResult = _filterSql(_filter!);
      buffer.write(filterResult.a);
      values.addAll(filterResult.b);
    }

    return Tuple(buffer.toString(), values);
  }

  Tuple<String, Map<String, dynamic>> _filterSql(Filter filter) {
    final buffer = StringBuffer();
    final values = <String, dynamic>{};

    if (filter is FilterGroup) {
      final results = filter.filters.map((e) => _filterSql(e));
      //TODO think about how to make substitution values unique
      values.addEntries(results.expand((e) => e.b.entries));

      switch(filter.type) {
        case FilterGroupType.And:
          buffer.write(results.map((e) => '(${e.a})').join(' AND '));
          break;
        case FilterGroupType.Or:
          buffer.write(results.map((e) => '(${e.a})').join(' OR '));
          break;
      }
    } else if (filter is PropertyCompare) {
      buffer.write(filter.propertyName);
      switch(filter.type) {
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
      buffer.write(_escapeValue(filter.value));
    }

    return Tuple(buffer.toString(), values);
  }
}

//TODO collations, constraints, ...
//maybe even inheritance
class CreateTableBuilder implements SqlBuilder {
  final bool ifNotExists;
  final String schemaName;
  final String tableName;
  final List<DataField> fields = [];

  CreateTableBuilder(this.schemaName, this.tableName,
      {this.ifNotExists = false});

  factory CreateTableBuilder.fromLayout(DataSchema schema, DataLayout layout) {
    return CreateTableBuilder(schema.name, layout.name, ifNotExists: true)
      ..fields.addAll(layout.fields);
  }

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final buffer = StringBuffer('CREATE TABLE ');

    if (ifNotExists) {
      buffer.write('IF NOT EXISTS ');
    }

    buffer.write('${_escapeName(schemaName)}.${_escapeName(tableName)} (');

    buffer.write(fields.map(_createFieldSql).join(','));

    buffer.write(')');

    return Tuple(buffer.toString(), {});
  }

  String _createFieldSql(DataField field) {
    final buffer = StringBuffer(_escapeName(field.name));
    buffer.write(' ${_typeSql(field.type, field.length)}');
    if (field is PrimaryKey) {
      buffer.write(' PRIMARY KEY');
    } else if (!field.nullable) {
      buffer.write(' NOT NULL');
    }
    //TODO foreign key?
    return buffer.toString();
  }
}

class CreateSchemaBuilder implements SqlBuilder {
  final String schemaName;

  CreateSchemaBuilder(this.schemaName);

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    return Tuple('CREATE SCHEMA @name', {'name': schemaName});
  }
}

String _escapeName(String name) {
  if (name.isEmpty || name.length > 128) {
    throw PersistenceException('Field name "$name" has invalid length. '
        '(Must be in range 1 - 128)');
  }

  //TODO check for forbidden names like ANALYZE, BETWEEN, ...

  //TODO check for first letter restriction

  return '"$name"';
}


String _escapeValue(dynamic value) {
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

String _typeSql(FieldType type, int length) {
  switch (type) {
    case FieldType.String:
      return 'varchar($length)';
    case FieldType.Int:
      if (length == 16) {
        return 'int2';
      } else if (length == 32) {
        return 'int4';
      } else if (length == 64) {
        return 'int8';
      } else {
        throw PersistenceException(
            'PostgreSQL implementation does not support int length $length.'
            'Only 16, 32 or 64 allowed.)');
      }
    case FieldType.Float:
      if (length == 32) {
        return 'real';
      } else if (length == 64) {
        return 'double precision';
      } else {
        throw PersistenceException(
            'PostgreSQL implementation does not support float length $length.'
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
          'PostgreSQL implementation does not support data type $type.');
  }
}
