import 'dart:convert';
import 'dart:typed_data';
import 'package:boost/boost.dart';

import 'codec_exception.dart';
import 'data_object.dart';

typedef Encoder<T> = dynamic Function(T value);
typedef Decoder<T> = T Function(dynamic value, {String? name});

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
      DataObject() => value.toJson(),
      List<dynamic>() => encodeList(value, encodeDynamic),
      Map<String, dynamic>() => encodeMap(value, encodeDynamic),
      null => null,
      _ =>
        throw CodecException('Cannot encode ${value.runtimeType} dynamically.'),
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
    if (value is T) {
      return value;
    }

    if (TypeCheck<T>().isSupertypeOf<String>()) {
      return decodeString(value, name: name) as T;
    }

    if (TypeCheck<T>().isSupertypeOf<int>()) {
      return decodeInt(value, name: name) as T;
    }

    if (TypeCheck<T>().isSupertypeOf<double>()) {
      return decodeDouble(value, name: name) as T;
    }
    if (TypeCheck<T>().isSupertypeOf<bool>()) {
      return decodeBool(value, name: name) as T;
    }
    if (TypeCheck<T>().isSupertypeOf<DateTime>()) {
      return decodeDateTime(value, name: name) as T;
    }
    if (TypeCheck<T>().isSupertypeOf<Duration>()) {
      return decodeDuration(value, name: name) as T;
    }
    if (TypeCheck<T>().isSupertypeOf<Uint8List>()) {
      return decodeUint8List(value, name: name) as T;
    }

    if (TypeCheck<T>().isListOf<String>()) {
      return decodeList<String>(value, decodeString, name: name) as T;
    }

    if (TypeCheck<T>().isListOf<int>()) {
      return decodeList<int>(value, decodeInt, name: name) as T;
    }
    if (TypeCheck<T>().isListOf<double>()) {
      return decodeList<double>(value, decodeDouble, name: name) as T;
    }
    if (TypeCheck<T>().isListOf<bool>()) {
      return decodeList<bool>(value, decodeBool, name: name) as T;
    }
    if (TypeCheck<T>().isListOf<DateTime>()) {
      return decodeList<DateTime>(value, decodeDateTime, name: name) as T;
    }
    if (TypeCheck<T>().isListOf<Duration>()) {
      return decodeList<Duration>(value, decodeDuration, name: name) as T;
    }
    if (TypeCheck<T>().isListOf<Uint8List>()) {
      return decodeList<Uint8List>(value, decodeUint8List, name: name) as T;
    }

    throw CodecException('Cannot decode $T typed.');
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
      final tzMinutes =
          (e.timeZoneOffset.inMinutes % 60).toString().padLeft(2, '0');
      return '${e.toIso8601String()}$tzPrefix$tzHours:$tzMinutes';
    }
  }

  @override
  int encodeDuration(Duration e) => e.inMilliseconds;

  @override
  String encodeUint8List(Uint8List e) => base64Encode(e);

  @override
  String encodeEnum(Enum value) => value.name;

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
    return double.tryParse(e.toString()) ??
        (throw CodecException.typeMismatch(double, e.runtimeType, name));
  }

  @override
  int decodeInt(dynamic e, {String? name}) {
    return int.tryParse(e.toString()) ??
        (throw CodecException.typeMismatch(int, e.runtimeType, name));
  }

  num decodeNum(dynamic e, {String? name}) {
    return num.tryParse(e.toString()) ??
        (throw CodecException.typeMismatch(num, e.runtimeType, name));
  }

  @override
  bool decodeBool(dynamic e, {String? name}) {
    if (e is num) {
      return e > 0;
    }

    final str = e.toString().toLowerCase();
    if (str == 'true') {
      return true;
    } else if (str == 'false') {
      return false;
    }

    throw CodecException.typeMismatch(bool, e.runtimeType, name);
  }

  @override
  DateTime decodeDateTime(dynamic e, {String? name}) {
    if (e is int) {
      return DateTime.fromMillisecondsSinceEpoch(e, isUtc: true);
    }

    if (e is String) {
      final parsed = int.tryParse(e);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed, isUtc: true);
      }
    }

    return DateTime.tryParse(e.toString()) ??
        (throw CodecException.typeMismatch(DateTime, e.runtimeType, name));
  }

  @override
  Duration decodeDuration(dynamic e, {String? name}) {
    return int.tryParse(e.toString())
            ?.apply((millis) => Duration(milliseconds: millis)) ??
        (throw CodecException.typeMismatch(Duration, e.runtimeType, name));
  }

  @override
  Uint8List decodeUint8List(dynamic e, {String? name}) {
    return e is String
        ? base64Decode(e)
        : (throw CodecException.typeMismatch(Uint8List, e.runtimeType, name));
  }

  @override
  T decodeEnum<T extends Enum>(value, List<T> values, {String? name}) {
    return switch (value) {
      T() => value,
      String() when values.any((e) => e.name == value) =>
        values.firstWhere((e) => e.name == value),
      _ => throw CodecException.typeMismatch(T, value.runtimeType, name),
    };
  }

  @override
  List<T> decodeList<T>(
    dynamic value,
    T Function(dynamic, {String? name}) decodeItem, {
    String? name,
  }) {
    if (value is List<T>) {
      return value;
    } else if (value is List<dynamic>) {
      return value
          .mapIndexed(
            (e, i) => decodeItem(e, name: DataCodec.indexName(name, i)),
          )
          .toList();
    }

    throw CodecException.typeMismatch(List<T>, value.runtimeType, name);
  }

  @override
  List<dynamic> encodeList<T>(List<T> value, Encoder<T> encodeItem) {
    return value.map(encodeItem).toList();
  }

  @override
  Map<String, T> decodeMap<T>(dynamic value, Decoder<T> decodeItem,
      {String? name}) {
    if (value is Map<String, T>) {
      return value;
    } else if (value is Map<String, dynamic>) {
      return value.map((k, v) =>
          MapEntry(k, decodeItem(v, name: DataCodec.indexName(name, k))));
    } else if (value is Map && value.isEmpty) {
      return <String, T>{};
    }

    throw CodecException.typeMismatch(Map<String, T>, value.runtimeType, name);
  }

  @override
  Map<String, dynamic> encodeMap<T>(
    Map<String, T> value,
    Encoder<T> encodeItem,
  ) {
    return value.map((k, v) => MapEntry(k, encodeItem(v)));
  }
}
