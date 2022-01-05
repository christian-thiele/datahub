import 'dart:typed_data';
import 'package:boost/boost.dart';

import 'encoding.dart';
import 'transfer_object.dart';

/// Represents a DTO-Field
/// supported types are
/// String, int, double, bool, DateTime, UInt8List, TransferObject
/// Uint8List is expected to be encoded as Base64
class Field<T> {
  final String name;
  final String key;

  final T? defaultValue;
  final DTOFactory? factory;

  const Field(this.name, {String? key, this.defaultValue, this.factory})
      : key = key ?? name;

  //TODO this is api specific, should be somewhere in api classes to avoid confusion with persistence usage
  T? decode(Map<String, dynamic> map) {
    if (map[key] == null) {
      return defaultValue;
    }

    return decodeTyped<T>(map[key], factory: factory);
  }

  //TODO this is api specific, should be somewhere in api classes to avoid confusion with persistence usage
  MapEntry<String, dynamic> encode(T value) {
    return MapEntry(key, value != null ? encodeTyped<T>(value) : defaultValue);
  }
}

class StrField extends Field<String> {
  const StrField(String name, {String? key, String? defaultValue})
      : super(name, key: key, defaultValue: defaultValue);
}

class IntField extends Field<int> {
  const IntField(String name, {String? key, int? defaultValue})
      : super(name, key: key, defaultValue: defaultValue);
}

class DoubleField extends Field<double> {
  const DoubleField(String name, {String? key, double? defaultValue})
      : super(name, key: key, defaultValue: defaultValue);
}

class BoolField extends Field<bool> {
  const BoolField(String name, {String? key, bool? defaultValue})
      : super(name, key: key, defaultValue: defaultValue);
}

class DateTimeField extends Field<DateTime> {
  const DateTimeField(String name, {String? key, DateTime? defaultValue})
      : super(name, key: key, defaultValue: defaultValue);
}

class ByteField extends Field<Uint8List> {
  const ByteField(String name, {String? key, Uint8List? defaultValue})
      : super(name, key: key, defaultValue: defaultValue);
}

class ObjectField<T extends TransferObject> extends Field<T> {
  const ObjectField(String name, {required DTOFactory factory, String? key})
      : super(name, key: key, factory: factory);
}

class EnumField<T> extends Field<T> {
  final bool ignoreCase;
  final List<T> values;

  const EnumField(String name, this.values,
      {String? key, T? defaultValue, this.ignoreCase = false})
      : super(name, key: key, defaultValue: defaultValue);

  @override
  T? decode(Map<String, dynamic> map) {
    if (map[key] == null) {
      return defaultValue;
    }

    return tryFindEnum(map[key].toString(), values, ignoreCase: ignoreCase);
  }

  @override
  MapEntry<String, dynamic> encode(T value) {
    final str = value.toString();
    return MapEntry(key, str.substring(str.lastIndexOf('.') + 1));
  }
}

/// Represents a list field where T defines the entry type
/// i.e. ListField<String> provides a List<String> as decoded type
class ListField<T> extends Field<List<T>> {
  const ListField(String name, {String? key, DTOFactory? factory})
      : super(name, key: key, factory: factory);

  @override
  List<T> decode(Map<String, dynamic> map) {
    if (map[key] == null) {
      return [];
    }

    final raw = map[key];

    if (raw is List) {
      return raw
          .map((e) => decodeTyped<T>(e, factory: factory))
          .whereNotNull
          .toList();
    }

    return [];
  }

  @override
  MapEntry<String, dynamic> encode(List<T> value) {
    return MapEntry(key, value.map((e) => encodeTyped<T>(e)).toList());
  }
}
