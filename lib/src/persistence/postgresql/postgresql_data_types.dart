import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/src/persistence/postgresql/sql/sql.dart';
import 'package:postgres/postgres.dart';

import 'sql/param_sql.dart';

abstract class PostgresqlDataType<T, TDataType extends DataType<T>> {
  const PostgresqlDataType();

  ParamSql getTypeSql(TDataType type);

  ParamSql toPostgresValue(TDataType type, T? data);

  T? toDaoValue(dynamic data);
}

class PostgresqlStringDataType
    extends PostgresqlDataType<String, StringDataType> {
  const PostgresqlStringDataType();

  @override
  ParamSql getTypeSql(StringDataType type) =>
      ParamSql('varchar(${type.length})');

  @override
  String? toDaoValue(dynamic data) => data?.toString();

  @override
  ParamSql toPostgresValue(StringDataType type, String? data) {
    return ParamSql.param(data, PostgreSQLDataType.text);
  }
}

class PostgresqlIntDataType extends PostgresqlDataType<int, IntDataType> {
  const PostgresqlIntDataType();

  @override
  ParamSql getTypeSql(IntDataType type) {
    if (type.length == 16) {
      return ParamSql('int2');
    } else if (type.length == 32) {
      return ParamSql('int4');
    } else if (type.length == 64) {
      return ParamSql('int8');
    } else {
      throw PersistenceException(
          'PostgreSQL implementation does not support int length ${type.length}.'
          'Only 16, 32 or 64 allowed.)');
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
  ParamSql toPostgresValue(IntDataType type, int? data) {
    if (type.length == 32) {
      return ParamSql.param<int>(data, PostgreSQLDataType.integer);
    } else if (type.length == 64) {
      return ParamSql.param<int>(data, PostgreSQLDataType.bigInteger);
    } else {
      throw PersistenceException(
          'PostgreSQL implementation does not support serial length ${type.length}.'
          'Only 32 or 64 allowed.)');
    }
  }
}

class PostgresqlSerialDataType extends PostgresqlDataType<int, SerialDataType> {
  const PostgresqlSerialDataType();

  @override
  ParamSql getTypeSql(SerialDataType type) {
    if (type.length == 32) {
      return ParamSql('serial');
    } else if (type.length == 64) {
      return ParamSql('bigserial');
    } else {
      throw PersistenceException(
          'PostgreSQL implementation does not support serial length ${type.length}.'
          'Only 32 or 64 allowed.)');
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
        'Invalid result type for PostgresqlSerialDataType.');
  }

  @override
  ParamSql toPostgresValue(SerialDataType type, int? data) {
    if (type.length == 32) {
      return ParamSql.param<int>(data, PostgreSQLDataType.integer);
    } else if (type.length == 64) {
      return ParamSql.param<int>(data, PostgreSQLDataType.bigInteger);
    } else {
      throw PersistenceException(
          'PostgreSQL implementation does not support serial length ${type.length}.'
          'Only 32 or 64 allowed.)');
    }
  }
}

class PostgresqlBoolDataType extends PostgresqlDataType<bool, BoolDataType> {
  const PostgresqlBoolDataType();

  @override
  ParamSql getTypeSql(BoolDataType type) => ParamSql('boolean');

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
  ParamSql toPostgresValue(BoolDataType type, bool? data) =>
      ParamSql.param<bool>(data, PostgreSQLDataType.boolean);
}

class PostgresqlDoubleDataType
    extends PostgresqlDataType<double, DoubleDataType> {
  const PostgresqlDoubleDataType();

  @override
  ParamSql getTypeSql(DoubleDataType type) {
    if (type.length == 16) {
      return ParamSql('int2');
    } else if (type.length == 32) {
      return ParamSql('int4');
    } else if (type.length == 64) {
      return ParamSql('int8');
    } else {
      throw PersistenceException(
          'PostgreSQL implementation does not support int length ${type.length}.'
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
  ParamSql toPostgresValue(DoubleDataType type, double? data) =>
      ParamSql.param<double>(data, PostgreSQLDataType.double);
}

class PostgresqlDateTimeDataType
    extends PostgresqlDataType<DateTime, DateTimeDataType> {
  const PostgresqlDateTimeDataType();

  @override
  ParamSql getTypeSql(DateTimeDataType type) =>
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
  ParamSql toPostgresValue(DateTimeDataType type, DateTime? data) =>
      ParamSql.param<DateTime>(data, PostgreSQLDataType.timestampWithTimezone);
}

class PostgresqlByteDataType
    extends PostgresqlDataType<Uint8List, ByteDataType> {
  const PostgresqlByteDataType();

  @override
  ParamSql getTypeSql(ByteDataType type) => ParamSql('bytea');

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
  ParamSql toPostgresValue(ByteDataType type, Uint8List? data) =>
      ParamSql.param<List<int>>(data, PostgreSQLDataType.byteArray);
}

class PostgresqlJsonMapDataType
    extends PostgresqlDataType<Map<String, dynamic>, JsonMapDataType> {
  const PostgresqlJsonMapDataType();

  @override
  ParamSql getTypeSql(JsonMapDataType type) => ParamSql('jsonb');

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
  ParamSql toPostgresValue(JsonMapDataType type, Map<String, dynamic>? data) {
    return ParamSql.param(data, PostgreSQLDataType.jsonb);
  }
}
