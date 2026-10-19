import 'dart:typed_data';

import 'package:datahub/data.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:postgres/postgres.dart' as pg;

import 'postgresql_data_type.dart';
import 'type_decode_exception.dart';

class const PostgresqlInt() extends PostgresqlDataType<int> {
  this : super('bigint', pg.Type.bigInteger);
}

class const PostgresqlSerial() extends PostgresqlDataType<int> {
  this : super('serial8', pg.Type.bigSerial);
}

class const PostgresqlDouble() extends PostgresqlDataType<double> {
  this : super('double precision', pg.Type.double);
}

class const PostgresqlBool() extends PostgresqlDataType<bool> {
  this : super('boolean', pg.Type.boolean);
}

class const PostgresqlDateTime() extends PostgresqlDataType<DateTime> {
  this : super('timestamp', pg.Type.timestamp);
}

class const PostgresqlString() extends PostgresqlDataType<String> {
  this : super('varchar', pg.Type.varChar);
}

class const PostgresqlText() extends PostgresqlDataType<String> {
  this : super('text', pg.Type.text);
}

class const PostgresqlEnum({final List<Enum>? values})
    extends PostgresqlDataType<Enum> {
  this : super('varchar', pg.Type.varChar);

  @override
  dynamic encode(Enum? value) => value?.name;

  @override
  Enum? decode(dynamic value) => _decodeElement(values, value);

  static Enum? _decodeElement(List<Enum>? values, dynamic value) {
    if (value == null) {
      return null;
    }

    if (values == null) {
      return switch (value) {
        Enum() => value,
        String() => values!.firstWhere(
          (e) => e.name == value,
          orElse: () => throw TypeDecodeException(
            'Invalid enum: "${value.toString().substring(0, 100)}"',
          ),
        ),
        _ => throw TypeDecodeException.typeMismatch(Enum, value.runtimeType),
      };
    } else {
      switch (value) {
        case Enum():
          if (values.contains(value)) {
            return value;
          } else {
            throw TypeDecodeException(
              'Invalid enum: "${value.toString().substring(0, 100)}"',
            );
          }
        case null:
          return null;
        default:
          return values.firstWhere(
            (e) => e.name == value.toString(),
            orElse: () => throw TypeDecodeException(
              'Invalid enum: "${value.toString().substring(0, 100)}"',
            ),
          );
      }
    }
  }
}

abstract interface class PostgresqlArray<T>();

class const PostgresqlStringArray()
    extends PostgresqlDataType<List<String>>
    implements PostgresqlArray<String> {
  this : super('_varchar', pg.Type.varCharArray);

  @override
  List<String>? decode(value) {
    return switch (value) {
      List<String?>() => value.nonNulls.toList(),
      String() => [value],
      null => null,
      _ => throw TypeDecodeException.typeMismatch(
        List<String>,
        value.runtimeType,
      ),
    };
  }
}

class const PostgresqlIntArray()
    extends PostgresqlDataType<List<int>>
    implements PostgresqlArray<int> {
  this : super('_int8', pg.Type.bigIntegerArray);

  @override
  List<int>? decode(value) {
    return switch (value) {
      List<int?>() => value.nonNulls.toList(),
      int() => [value],
      null => null,
      _ => throw TypeDecodeException.typeMismatch(List<int>, value.runtimeType),
    };
  }
}

class const PostgresqlDoubleArray()
    extends PostgresqlDataType<List<double>>
    implements PostgresqlArray<double> {
  this : super('_float8', pg.Type.doubleArray);

  @override
  List<double>? decode(value) {
    return switch (value) {
      List<double?>() => value.nonNulls.toList(),
      double() => [value],
      null => null,
      _ => throw TypeDecodeException.typeMismatch(
        List<double>,
        value.runtimeType,
      ),
    };
  }
}

class const PostgresqlBoolArray()
    extends PostgresqlDataType<List<bool>>
    implements PostgresqlArray<bool> {
  this : super('_boolean', pg.Type.booleanArray);

  @override
  List<bool>? decode(value) {
    return switch (value) {
      List<bool?>() => value.nonNulls.toList(),
      bool() => [value],
      null => null,
      _ => throw TypeDecodeException.typeMismatch(
        List<bool>,
        value.runtimeType,
      ),
    };
  }
}

class const PostgresqlEnumArray({final List<Enum>? values})
    extends PostgresqlDataType<List<Enum>>
    implements PostgresqlArray<Enum> {
  this : super('_varchar', pg.Type.varCharArray);

  @override
  dynamic encode(List<Enum>? value) => value?.map((e) => e.name).toList();

  @override
  List<Enum>? decode(dynamic value) {
    return switch (value) {
      List<String>() =>
        value
            .map((e) => PostgresqlEnum._decodeElement(values, e))
            .nonNulls
            .toList(),
      List() when value.isEmpty => const <Enum>[],
      _ => throw TypeDecodeException.typeMismatch(
        List<Enum>,
        value.runtimeType,
      ),
    };
  }
}

class const PostgresqlByteArray()
    extends PostgresqlDataType<Uint8List>
    implements PostgresqlArray {
  this : super('bytea', pg.Type.byteArray);
}

interface class PostgresqlJson();

class const PostgresqlJsonMap()
    extends PostgresqlDataType<Map<String, dynamic>>
    implements PostgresqlJson {
  this : super('jsonb', pg.Type.jsonb);
}

class const PostgresqlJsonList()
    extends PostgresqlDataType<List<dynamic>>
    implements PostgresqlJson {
  this : super('jsonb', pg.Type.jsonb);
}

class const PostgresqlDynamic()
    extends PostgresqlDataType<dynamic>
    implements PostgresqlJson {
  this : super('jsonb', pg.Type.jsonb);
}

/// jsonb map that represents a DataObject
class const PostgresqlObject<T>(
  final Encoder<T> encoder,
  final Decoder<T> decoder,
) extends PostgresqlDataType<T> implements PostgresqlJson {
  this : super('jsonb', pg.Type.jsonb);

  @override
  dynamic encode(T? value) => (value != null) ? encoder(value) : null;

  @override
  T? decode(dynamic value) {
    return switch (value) {
      null => null,
      _ => decoder(value),
    };
  }
}

/// jsonb list of maps that represent DataObjects
class const PostgresqlObjectList<T>(
  final Encoder<T> encoder,
  final Decoder<T> decoder,
) extends PostgresqlDataType<T> implements PostgresqlJson {
  this : super('jsonb', pg.Type.jsonb);

  @override
  dynamic encode(T? value) => (value != null) ? encoder(value) : null;

  @override
  T? decode(dynamic value) {
    return switch (value) {
      null => null,
      _ => decoder(value),
    };
  }
}

class const PostgresqlNull() extends PostgresqlDataType<dynamic> {
  this : super('NULL', pg.Type.unspecified);

  @override
  dynamic encode(dynamic value) => null;

  @override
  List<dynamic>? decode(value) => null;

  @override
  Sql sqlParam(value) => const RawSql('NULL');
}
