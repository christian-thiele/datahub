import 'dart:convert';
import 'dart:typed_data';
import 'package:boost/boost.dart';

import 'codec_exception.dart';
import 'data_enum.dart';
import 'data_object.dart';
import 'types/geometry/geometry.dart';

typedef Encoder<T> = dynamic Function(T value);
typedef Decoder<T> = T Function(dynamic value, {String? name});
typedef CompoundEncoder<C, T> = dynamic Function(C value, Encoder<T> encoder);
typedef CompoundDecoder<C, T> =
    C Function(dynamic value, Decoder<T> encoder, {String? name});

abstract class DataCodec {
  const DataCodec();

  dynamic encodeString(String value);

  dynamic encodeInt(int value);

  dynamic encodeDouble(double value);

  dynamic encodeBool(bool value);

  dynamic encodeDateTime(DateTime value);

  dynamic encodeDuration(Duration value);

  dynamic encodeUint8List(Uint8List value);

  dynamic encodeEnum(Enum value);

  dynamic encodeGeometry(Geometry value);

  dynamic encodeList<T>(List<T> value, Encoder<T> encodeItem);

  dynamic encodeMap<T>(Map<String, T> value, Encoder<T> encodeItem);

  dynamic encodeDynamic(dynamic value) {
    return switch (value) {
      String() => encodeString(value),
      int() => encodeInt(value),
      double() => encodeDouble(value),
      bool() => encodeBool(value),
      DateTime() => encodeDateTime(value),
      Duration() => encodeDuration(value),
      Uint8List() => encodeUint8List(value),
      Enum() => encodeEnum(value),
      Geometry() => encodeGeometry(value),
      DataObject() => value.toJson(),
      List<dynamic>() => encodeList(value, encodeDynamic),
      Map<String, dynamic>() => encodeMap(value, encodeDynamic),
      null => null,
      _ => throw CodecException(
        'Cannot encode ${value.runtimeType} dynamically.',
        null,
      ),
    };
  }

  dynamic encodeNullable<T>(T? value, Encoder<T> encodeItem) {
    return value != null ? encodeItem(value) : null;
  }

  String decodeString(dynamic value, {String? name});

  int decodeInt(dynamic value, {String? name});

  double decodeDouble(dynamic value, {String? name});

  bool decodeBool(dynamic value, {String? name});

  DateTime decodeDateTime(dynamic value, {String? name});

  Duration decodeDuration(dynamic value, {String? name});

  Uint8List decodeUint8List(dynamic value, {String? name});

  T decodeEnum<T extends Enum>(dynamic value, List<T> values, {String? name});

  Geometry decodeGeometry(dynamic value, {String? name});

  List<T> decodeList<T>(dynamic v, Decoder<T> decodeItem, {String? name});

  Map<String, T> decodeMap<T>(
    dynamic v,
    Decoder<T> decoderItem, {
    String? name,
  });

  dynamic decodeDynamic(dynamic value, {String? name}) => value;

  T? decodeNullable<T>(dynamic value, Decoder<T> decodeItem, {String? name}) {
    return value != null ? decodeItem(value, name: name) : null;
  }

  T decodeTyped<T>(dynamic value, {String? name}) {
    return decodeType(TypeCheck<T>(), value) as T;
  }

  dynamic decodeType(TypeCheck type, dynamic value, {String? name}) {
    if (type.accepts(value)) {
      return value;
    }

    if (type.isSupertypeOf<String>()) {
      return decodeString(value, name: name);
    }

    if (type.isSupertypeOf<double>()) {
      return decodeDouble(value, name: name);
    }

    if (type.isSupertypeOf<int>()) {
      return decodeInt(value, name: name);
    }

    if (type.isSupertypeOf<bool>()) {
      return decodeBool(value, name: name);
    }
    if (type.isSupertypeOf<DateTime>()) {
      return decodeDateTime(value, name: name);
    }
    if (type.isSupertypeOf<Duration>()) {
      return decodeDuration(value, name: name);
    }

    if (type.isExact<Uint8List>() || type.isExact<Uint8List?>()) {
      return decodeUint8List(value, name: name);
    }

    if (type.isSupertypeOf<List<String>>()) {
      return decodeList<String>(value, decodeString, name: name);
    }
    if (type.isSupertypeOf<List<int>>()) {
      return decodeList<int>(value, decodeInt, name: name);
    }
    if (type.isSupertypeOf<List<double>>()) {
      return decodeList<double>(value, decodeDouble, name: name);
    }
    if (type.isSupertypeOf<List<bool>>()) {
      return decodeList<bool>(value, decodeBool, name: name);
    }
    if (type.isSupertypeOf<List<DateTime>>()) {
      return decodeList<DateTime>(value, decodeDateTime, name: name);
    }
    if (type.isSupertypeOf<List<Duration>>()) {
      return decodeList<Duration>(value, decodeDuration, name: name);
    }
    if (type.isSupertypeOf<List<Uint8List>>()) {
      return decodeList<Uint8List>(value, decodeUint8List, name: name);
    }

    throw CodecException('Cannot decode ${type.name} typed.', null);
  }

  static String? childName(String? parent, String? child) {
    if (child == null) {
      return null;
    } else if (parent == null) {
      return child;
    } else {
      return '$parent.$child';
    }
  }

  static String? indexName(String? parent, dynamic index) {
    if (parent != null) {
      return '$parent[$index]';
    } else {
      return '[$index]';
    }
  }
}

class JsonDataCodec extends DataCodec {
  const JsonDataCodec();

  @override
  String encodeString(String value) => value;

  @override
  int encodeInt(int value) => value;

  @override
  double encodeDouble(double value) => value;

  @override
  bool encodeBool(bool value) => value;

  @override
  String encodeDateTime(DateTime e) {
    if (e.isUtc) {
      return e.toIso8601String();
    } else {
      final tzPrefix = e.timeZoneOffset.isNegative ? '-' : '+';
      final tzHours = e.timeZoneOffset.inHours.abs().toString().padLeft(2, '0');
      final tzMinutes = (e.timeZoneOffset.inMinutes % 60).toString().padLeft(
        2,
        '0',
      );
      return '${e.toIso8601String()}$tzPrefix$tzHours:$tzMinutes';
    }
  }

  @override
  int encodeDuration(Duration e) => e.inMilliseconds;

  @override
  String encodeUint8List(Uint8List e) => base64Encode(e);

  @override
  String encodeEnum(Enum value) {
    return switch (value) {
      DataEnum(:final jsonValue) => jsonValue,
      _ => value.name,
    };
  }

  @override
  dynamic encodeGeometry(Geometry value) => base64Encode(value.toEWKB());

  @override
  String decodeString(dynamic e, {String? name}) {
    if (e is String || e is num || e is bool) {
      return e.toString();
    } else {
      throw CodecException.typeMismatch(String, e.runtimeType, name);
    }
  }

  @override
  double decodeDouble(dynamic e, {String? name}) {
    try {
      return switch (e) {
        double() => e,
        int() => e.toDouble(),
        String() => double.parse(e),
        _ => throw CodecException.typeMismatch(double, e.runtimeType, name),
      };
    } on FormatException catch (_) {
      throw CodecException.typeMismatch(double, e.runtimeType, name);
    }
  }

  @override
  int decodeInt(dynamic e, {String? name}) {
    try {
      return switch (e) {
        int() => e,
        double() when e.toInt() == e => e.toInt(),
        String() => int.parse(e),
        _ => throw CodecException.typeMismatch(int, e.runtimeType, name),
      };
    } on FormatException catch (_) {
      throw CodecException.typeMismatch(int, e.runtimeType, name);
    }
  }

  num decodeNum(dynamic e, {String? name}) {
    try {
      return switch (e) {
        double() => e,
        int() => e,
        String() => num.parse(e),
        _ => throw CodecException.typeMismatch(num, e.runtimeType, name),
      };
    } on FormatException catch (_) {
      throw CodecException.typeMismatch(num, e.runtimeType, name);
    }
  }

  @override
  bool decodeBool(dynamic e, {String? name}) {
    return switch (e) {
      bool() => e,
      num() => e > 0,
      '0' => false,
      '1' => true,
      String() when e.toLowerCase() == 'true' => true,
      String() when e.toLowerCase() == 'false' => false,
      _ => throw CodecException.typeMismatch(bool, e.runtimeType, name),
    };
  }

  @override
  DateTime decodeDateTime(dynamic e, {String? name}) {
    try {
      return switch (e) {
        DateTime() => e,
        int() => DateTime.fromMillisecondsSinceEpoch(e, isUtc: true),
        String() when int.tryParse(e) != null =>
          DateTime.fromMillisecondsSinceEpoch(int.parse(e), isUtc: true),
        String() => DateTime.parse(e.toString()),
        _ => throw CodecException.typeMismatch(DateTime, e.runtimeType, name),
      };
    } on FormatException catch (_) {
      throw CodecException.typeMismatch(DateTime, e.runtimeType, name);
    }
  }

  @override
  Duration decodeDuration(dynamic e, {String? name}) {
    try {
      return switch (e) {
        Duration() => e,
        int() => Duration(milliseconds: e),
        String() when int.tryParse(e) != null => Duration(
          milliseconds: int.parse(e),
        ),
        _ => throw CodecException.typeMismatch(Duration, e.runtimeType, name),
      };
    } on FormatException catch (_) {
      throw CodecException.typeMismatch(Duration, e.runtimeType, name);
    }
  }

  @override
  Uint8List decodeUint8List(dynamic e, {String? name}) {
    return switch (e) {
      Uint8List() => e,
      String() => base64Decode(e),
      _ => throw CodecException.typeMismatch(Uint8List, e.runtimeType, name),
    };
  }

  @override
  T decodeEnum<T extends Enum>(value, List<T> values, {String? name}) {
    return switch (value) {
          T() => value,
          String() => values.nonNulls.where((e) {
            return switch (e) {
              DataEnum(:final jsonValue) => jsonValue == value,
              Enum(:final name) => name == value,
            };
          }).firstOrNull,
          _ => null,
        } ??
        (throw CodecException.typeMismatch(T, value.runtimeType, name));
  }

  @override
  Geometry decodeGeometry(dynamic value, {String? name}) {
    return switch (value) {
      Geometry() => value,
      String() => Geometry.parseEWKB(base64Decode(value)),
      Uint8List() => Geometry.parseEWKB(value),
      _ => throw CodecException.typeMismatch(Geometry, value.runtimeType, name),
    };
  }

  @override
  List<T> decodeList<T>(
    dynamic value,
    T Function(dynamic, {String? name}) decodeItem, {
    String? name,
  }) {
    return switch (value) {
      List<T>() => value,
      List<dynamic>() =>
        value.indexed
            .map((e) => decodeItem(e.$2, name: DataCodec.indexName(name, e.$1)))
            .toList(),
      null => <T>[],
      _ => throw CodecException.typeMismatch(List<T>, value.runtimeType, name),
    };
  }

  @override
  List<dynamic> encodeList<T>(List<T> value, Encoder<T> encodeItem) {
    return value.map(encodeItem).toList();
  }

  @override
  Map<String, T> decodeMap<T>(
    dynamic value,
    Decoder<T> decodeItem, {
    String? name,
  }) {
    return switch (value) {
      Map<String, T>() => value,
      Map<String, dynamic>() => value.map(
        (k, v) =>
            MapEntry(k, decodeItem(v, name: DataCodec.indexName(name, k))),
      ),
      Map() when value.isEmpty => <String, T>{},
      null => <String, T>{},
      _ => throw CodecException.typeMismatch(
        Map<String, T>,
        value.runtimeType,
        name,
      ),
    };
  }

  @override
  Map<String, dynamic> encodeMap<T>(
    Map<String, T> value,
    Encoder<T> encodeItem,
  ) {
    return value.map((k, v) => MapEntry(k, encodeItem(v)));
  }
}
