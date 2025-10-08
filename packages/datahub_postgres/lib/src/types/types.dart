import 'dart:typed_data';

import 'package:datahub/data.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:datahub_postgres/src/types/type_decode_exception.dart';
import 'package:postgres/postgres.dart' as pg;

class PostgresqlInt extends PostgresqlDataType<int> {
  const PostgresqlInt() : super('bigint', pg.Type.bigInteger);
}

class PostgresqlSerial extends PostgresqlDataType<int> {
  const PostgresqlSerial() : super('serial8', pg.Type.bigSerial);
}

class PostgresqlDouble extends PostgresqlDataType<double> {
  const PostgresqlDouble() : super('double precision', pg.Type.double);
}

class PostgresqlBool extends PostgresqlDataType<bool> {
  const PostgresqlBool() : super('boolean', pg.Type.boolean);
}

class PostgresqlDateTime extends PostgresqlDataType<DateTime> {
  const PostgresqlDateTime() : super('timestamp', pg.Type.timestamp);
}

class PostgresqlString extends PostgresqlDataType<String> {
  const PostgresqlString() : super('varchar', pg.Type.varChar);
}

class PostgresqlText extends PostgresqlDataType<String> {
  const PostgresqlText() : super('text', pg.Type.text);
}

class PostgresqlEnum extends PostgresqlDataType<Enum> {
  final List<Enum>? values;

  const PostgresqlEnum({this.values}) : super('varchar', pg.Type.varChar);

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

class PostgresqlEnumArray extends PostgresqlDataType<List<Enum>> {
  final List<Enum>? values;

  const PostgresqlEnumArray({this.values})
    : super('_varchar', pg.Type.varCharArray);

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
      _ => throw TypeDecodeException.typeMismatch(
        List<Enum>,
        value.runtimeType,
      ),
    };
  }
}

class PostgresqlByteArray extends PostgresqlDataType<Uint8List> {
  const PostgresqlByteArray() : super('bytea', pg.Type.byteArray);
}

class PostgresqlJsonMap extends PostgresqlDataType<Map<String, dynamic>> {
  const PostgresqlJsonMap() : super('jsonb', pg.Type.jsonb);
}

class PostgresqlJsonList extends PostgresqlDataType<List<dynamic>> {
  const PostgresqlJsonList() : super('jsonb', pg.Type.jsonb);
}

class PostgresqlDynamic extends PostgresqlDataType<dynamic> {
  const PostgresqlDynamic() : super('jsonb', pg.Type.jsonb);
}

class PostgresqlStringArray extends PostgresqlDataType<List<String>> {
  const PostgresqlStringArray() : super('_varchar', pg.Type.varCharArray);

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

class PostgresqlIntArray extends PostgresqlDataType<List<int>> {
  const PostgresqlIntArray() : super('_int8', pg.Type.integerArray);

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

class PostgresqlDoubleArray extends PostgresqlDataType<List<double>> {
  const PostgresqlDoubleArray() : super('_float8', pg.Type.doubleArray);

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

class PostgresqlBoolArray extends PostgresqlDataType<List<bool>> {
  const PostgresqlBoolArray() : super('_boolean', pg.Type.booleanArray);

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

class PostgresqlObject<T> extends PostgresqlDataType<T> {
  final Encoder<T> encoder;
  final Decoder<T> decoder;

  const PostgresqlObject(this.encoder, this.decoder)
    : super('jsonb', pg.Type.jsonb);

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
