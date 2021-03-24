import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/src/persistence/persistence_exception.dart';

abstract class SqlBuilder {
  String buildSql();
}

//TODO collations, constraints, ...
//maybe even inheritance
class CreateTableBuilder implements SqlBuilder {
  final bool ifNotExists;
  final String tableName;
  final List<DataField> fields = [];

  CreateTableBuilder(this.tableName, {this.ifNotExists = false});

  @override
  String buildSql() {
    final buffer = StringBuffer('CREATE TABLE ');

    if (ifNotExists) {
      buffer.write('IF NOT EXISTS ');
    }

    buffer.write('${_escapeName(tableName)} (');

    buffer.write(fields.map(_createFieldSql).join(','));

    buffer.write(')');

    return buffer.toString();
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

String _escapeName(String name) {
  if (name.isEmpty || name.length > 128) {
    throw PersistenceException('Field name "$name" has invalid length. '
        '(Must be in range 1 - 128)');
  }

  //TODO check for forbidden names like ANALYZE, BETWEEN, ...

  //TODO check for first letter restriction

  return '"$name"';
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
