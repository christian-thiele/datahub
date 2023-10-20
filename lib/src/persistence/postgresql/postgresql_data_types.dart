import 'dart:typed_data';

import 'package:datahub/persistence.dart';
import 'package:postgres/postgres.dart';

import 'sql/param_sql.dart';

abstract class PostgresqlDataType<T, TDataType extends DataType<T>> {
  Type get baseType => TDataType;

  const PostgresqlDataType();

  ParamSql getTypeSql(DataField field);

  ParamSql toPostgresValue(DataField field, T? data);

  T? toDaoValue(dynamic data);
}

class PostgresqlStringDataType
    extends PostgresqlDataType<String, StringDataType> {
  const PostgresqlStringDataType();

  @override
  ParamSql getTypeSql(DataField field) {
    final length = field.length == 0 ? 255 : field.length;
    return ParamSql('varchar($length)');
  }

  @override
  String? toDaoValue(dynamic data) => data?.toString();

  @override
  ParamSql toPostgresValue(DataField field, String? data) {
    return ParamSql.param(data, PostgreSQLDataType.varChar);
  }
}

class PostgresqlIntDataType extends PostgresqlDataType<int, IntDataType> {
  const PostgresqlIntDataType();

  @override
  ParamSql getTypeSql(DataField field) {
    if (field is PrimaryKey && field.autoIncrement) {
      if (field.length == 16) {
        return ParamSql('smallserial');
      } else if (field.length == 32) {
        return ParamSql('serial');
      } else if (field.length == 64 || field.length == 0) {
        return ParamSql('bigserial');
      } else {
        throw PersistenceException(
            'PostgreSQL implementation does not support serial length ${field.length}.'
                ' Only 32 or 64 allowed.)');
      }
    }else {
      if (field.length == 16) {
        return ParamSql('int2');
      } else if (field.length == 32) {
        return ParamSql('int4');
      } else if (field.length == 64 || field.length == 0) {
        return ParamSql('int8');
      } else {
        throw PersistenceException(
            'PostgreSQL implementation does not support int length ${field
                .length}.'
                ' Only 16, 32 or 64 allowed.)');
      }
    }
  }

  @override
  int? toDaoValue(data) {
    if (data == null) {
      return null;
    }

    if (data is int) {
      return data;
    }

    if (data is num) {
      return data.toInt();
    }

    throw PersistenceException(
        'Invalid result type for PostgresqlIntDataType.');
  }

  @override
  ParamSql toPostgresValue(DataField field, int? data) {
    if (field.length == 32) {
      return ParamSql.param<int>(data, PostgreSQLDataType.integer);
    } else if (field.length == 64 || field.length == 0) {
      return ParamSql.param<int>(data, PostgreSQLDataType.bigInteger);
    } else {
      throw PersistenceException(
          'PostgreSQL implementation does not support int length ${field.length}.'
          'Only 32 or 64 allowed.)');
    }
  }
}

class PostgresqlBoolDataType extends PostgresqlDataType<bool, BoolDataType> {
  const PostgresqlBoolDataType();

  @override
  ParamSql getTypeSql(DataField field) => ParamSql('boolean');

  @override
  bool? toDaoValue(data) {
    if (data == null) {
      return null;
    }

    if (data is bool) {
      return data;
    }

    if (data is num) {
      return data > 0;
    }

    throw PersistenceException(
        'Invalid result type for PostgresqlBoolDataType.');
  }

  @override
  ParamSql toPostgresValue(DataField field, bool? data) =>
      ParamSql.param<bool>(data, PostgreSQLDataType.boolean);
}

class PostgresqlDoubleDataType
    extends PostgresqlDataType<double, DoubleDataType> {
  const PostgresqlDoubleDataType();

  @override
  ParamSql getTypeSql(DataField field) {
    if (field.length == 32) {
      return ParamSql('real');
    } else if (field.length == 64 || field.length == 0) {
      return ParamSql('double precision');
    } else {
      throw PersistenceException(
          'PostgreSQL implementation does not support int length ${field.length}.'
          'Only 16, 32 or 64 allowed.)');
    }
  }

  @override
  double? toDaoValue(data) {
    if (data == null) {
      return null;
    }

    if (data is num) {
      return data.toDouble();
    }

    throw PersistenceException(
        'Invalid result type for PostgresqlIntDataType.');
  }

  @override
  ParamSql toPostgresValue(DataField field, double? data) =>
      ParamSql.param<double>(data, PostgreSQLDataType.double);
}

class PostgresqlDateTimeDataType
    extends PostgresqlDataType<DateTime, DateTimeDataType> {
  const PostgresqlDateTimeDataType();

  @override
  ParamSql getTypeSql(DataField field) =>
      ParamSql('timestamp with time zone');

  @override
  DateTime? toDaoValue(data) {
    if (data == null) {
      return null;
    }

    if (data is DateTime) {
      return data;
    }

    if (data is int) {
      return DateTime.fromMillisecondsSinceEpoch(data);
    }

    if (data is String) {
      return DateTime.parse(data);
    }

    throw PersistenceException(
        'Invalid result type for PostgresqlDateTimeDataType.');
  }

  @override
  ParamSql toPostgresValue(DataField field, DateTime? data) =>
      ParamSql.param<DateTime>(data, PostgreSQLDataType.timestampWithTimezone);
}

class PostgresqlByteDataType
    extends PostgresqlDataType<Uint8List, ByteDataType> {
  const PostgresqlByteDataType();

  @override
  ParamSql getTypeSql(DataField field) => ParamSql('bytea');

  @override
  Uint8List? toDaoValue(data) {
    if (data == null) {
      return null;
    }

    if (data is Uint8List) {
      return data;
    }

    //TODO parse data

    throw PersistenceException(
        'Invalid result type for PostgresqlDateTimeDataType.');
  }

  @override
  ParamSql toPostgresValue(DataField field, Uint8List? data) =>
      ParamSql.param<List<int>>(data, PostgreSQLDataType.byteArray);
}

class PostgresqlJsonMapDataType
    extends PostgresqlDataType<Map<String, dynamic>, JsonMapDataType> {
  const PostgresqlJsonMapDataType();

  @override
  ParamSql getTypeSql(DataField field) => ParamSql('jsonb');

  @override
  Map<String, dynamic>? toDaoValue(data) {
    if (data == null) {
      return null;
    }

    if (data is Map<String, dynamic>) {
      return data;
    }

    //TODO parse data

    throw PersistenceException(
        'Invalid result type for PostgresqlDateTimeDataType.');
  }

  @override
  ParamSql toPostgresValue(DataField field, Map<String, dynamic>? data) {
    return ParamSql.param(data, PostgreSQLDataType.jsonb);
  }
}
