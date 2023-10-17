import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/src/persistence/postgresql/sql/sql.dart';

abstract class PostgresqlDataType<T, TDataType extends DataType<T>> {
  const PostgresqlDataType();

  String getTypeSql(TDataType type);

  String toPostgresValue(T? data);

  T? toDaoValue(dynamic data);
}

class PostgresqlStringDataType
    extends PostgresqlDataType<String, StringDataType> {
  const PostgresqlStringDataType();

  @override
  String getTypeSql(StringDataType type) => 'varchar(${type.length})';

  @override
  String? toDaoValue(dynamic data) => data?.toString();

  @override
  String toPostgresValue(String? data) {
    if (data == null) {
      return 'NULL';
    }

    //TODO other escape things
    return '\'${data.toString().replaceAll('\'', '\'\'')}\'';
  }
}

class PostgresqlIntDataType extends PostgresqlDataType<int, IntDataType> {
  const PostgresqlIntDataType();

  @override
  String getTypeSql(IntDataType type) {
    if (type.length == 16) {
      return 'int2';
    } else if (type.length == 32) {
      return 'int4';
    } else if (type.length == 64) {
      return 'int8';
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
  String toPostgresValue(int? data) => data?.toString() ?? 'NULL';
}

class PostgresqlSerialDataType extends PostgresqlDataType<int, SerialDataType> {
  const PostgresqlSerialDataType();

  @override
  String getTypeSql(SerialDataType type) {
    if (type.length == 32) {
      return 'serial';
    } else if (type.length == 64) {
      return 'bigserial';
    } else {
      throw PersistenceException(
          'PostgreSQL implementation does not support serial length ${type.length}.'
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
        'Invalid result type for PostgresqlSerialDataType.');
  }

  @override
  String toPostgresValue(int? data) => data?.toString() ?? 'NULL';
}

class PostgresqlBoolDataType extends PostgresqlDataType<bool, BoolDataType> {
  const PostgresqlBoolDataType();

  @override
  String getTypeSql(BoolDataType type) => 'boolean';

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
  String toPostgresValue(bool? data) =>
      data?.apply((p0) => p0 ? 'true' : 'false') ?? 'NULL';
}

class PostgresqlDoubleDataType
    extends PostgresqlDataType<double, DoubleDataType> {
  const PostgresqlDoubleDataType();

  @override
  String getTypeSql(DoubleDataType type) {
    if (type.length == 16) {
      return 'int2';
    } else if (type.length == 32) {
      return 'int4';
    } else if (type.length == 64) {
      return 'int8';
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
  String toPostgresValue(double? data) => data?.toString() ?? 'NULL';
}

class PostgresqlDateTimeDataType
    extends PostgresqlDataType<DateTime, DateTimeDataType> {
  const PostgresqlDateTimeDataType();

  @override
  String getTypeSql(DateTimeDataType type) => 'timestamp with time zone';

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
  String toPostgresValue(DateTime? data) =>
      data?.apply((d) => '\'${d.toIso8601String()}\'') ?? 'NULL';
}

class PostgresqlByteDataType
    extends PostgresqlDataType<Uint8List, ByteDataType> {
  const PostgresqlByteDataType();

  @override
  String getTypeSql(ByteDataType type) => 'bytea';

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
  String toPostgresValue(Uint8List? data) =>
      data?.apply((d) => 'decode(\'${d.toHexString()}\', \'hex\')') ?? 'NULL';
}

class PostgresqlJsonMapDataType
    extends PostgresqlDataType<Map<String, dynamic>, JsonMapDataType> {
  const PostgresqlJsonMapDataType();

  @override
  String getTypeSql(JsonMapDataType type) => 'jsonb';

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
  String toPostgresValue(Map<String, dynamic>? data) {
    if (data == null) {
      return 'NULL';
    } else {
      final escapedJson = SqlBuilder.escapeValue(jsonEncode(data));
      return '\'$escapedJson\'::jsonb';
    }
  }
}
