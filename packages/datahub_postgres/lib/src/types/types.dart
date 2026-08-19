import 'dart:typed_data';

import 'package:datahub/data.dart';
import 'package:datahub/datahub.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:datahub_postgres/sql.dart';

import 'postgresql_data_type.dart';
import 'type_decode_exception.dart';

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

abstract interface class PostgresqlArray<T> {}

class PostgresqlStringArray extends PostgresqlDataType<List<String>>
    implements PostgresqlArray<String> {
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

class PostgresqlIntArray extends PostgresqlDataType<List<int>>
    implements PostgresqlArray<int> {
  const PostgresqlIntArray() : super('_int8', pg.Type.bigIntegerArray);

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

class PostgresqlDoubleArray extends PostgresqlDataType<List<double>>
    implements PostgresqlArray<double> {
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

class PostgresqlBoolArray extends PostgresqlDataType<List<bool>>
    implements PostgresqlArray<bool> {
  const PostgresqlBoolArray() : super('_bool', pg.Type.booleanArray);

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

class PostgresqlEnumArray extends PostgresqlDataType<List<Enum>>
    implements PostgresqlArray<Enum> {
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
      List() when value.isEmpty => const <Enum>[],
      _ => throw TypeDecodeException.typeMismatch(
        List<Enum>,
        value.runtimeType,
      ),
    };
  }
}

class PostgresqlByteArray extends PostgresqlDataType<Uint8List>
    implements PostgresqlArray {
  const PostgresqlByteArray() : super('bytea', pg.Type.byteArray);
}

interface class PostgresqlJson {}

class PostgresqlJsonMap extends PostgresqlDataType<Map<String, dynamic>>
    implements PostgresqlJson {
  const PostgresqlJsonMap() : super('jsonb', pg.Type.jsonb);
}

class PostgresqlJsonList extends PostgresqlDataType<List<dynamic>>
    implements PostgresqlJson {
  const PostgresqlJsonList() : super('jsonb', pg.Type.jsonb);
}

class PostgresqlDynamic extends PostgresqlDataType<dynamic>
    implements PostgresqlJson {
  const PostgresqlDynamic() : super('jsonb', pg.Type.jsonb);
}

/// jsonb map that represents a DataObject
class PostgresqlObject<T> extends PostgresqlDataType<T>
    implements PostgresqlJson {
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

/// jsonb list of maps that represent DataObjects
class PostgresqlObjectList<T> extends PostgresqlDataType<T>
    implements PostgresqlJson {
  final Encoder<T> encoder;
  final Decoder<T> decoder;

  const PostgresqlObjectList(this.encoder, this.decoder)
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

class PostgresqlNull extends PostgresqlDataType<dynamic> {
  const PostgresqlNull() : super('NULL', pg.Type.unspecified);

  @override
  dynamic encode(dynamic value) => null;

  @override
  List<dynamic>? decode(value) => null;

  @override
  Sql sqlParam(value) => RawSql('NULL');
}
