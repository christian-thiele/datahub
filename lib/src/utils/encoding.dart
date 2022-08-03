import 'dart:convert';
import 'dart:typed_data';
import 'package:boost/boost.dart';
import 'package:datahub/utils.dart';

T decodeTyped<T>(dynamic raw) {
  return decodeTypedNullable(raw) ?? (throw ApiException('Missing value.'));
}

T? decodeTypedNullable<T>(dynamic raw) {
  final type = TypeCheck<T>();

  if (raw == null || type.isSubtypeOf<Null>()) {
    return null;
  }

  if (raw is T) {
    return raw;
  }

  if (type.isSubtypeOf<String?>()) {
    return raw.toString() as T;
  }

  if (type.isSubtypeOf<int?>()) {
    final result = int.tryParse(raw.toString());
    return (result is T) ? result as T : null;
  }

  if (type.isSubtypeOf<double?>()) {
    final result = double.tryParse(raw.toString());
    return (result is T) ? result as T : null;
  }

  if (type.isSubtypeOf<bool?>()) {
    if (raw is num) {
      return raw > 0 as T;
    }

    if (raw.toString().toLowerCase() == 'true') {
      return true as T;
    } else if (raw.toString().toLowerCase() == 'false') {
      return false as T;
    }

    return null;
  }

  if (type.isSubtypeOf<DateTime?>()) {
    final result = DateTime.tryParse(raw.toString());
    return (result is T) ? result as T : null;
  }

  if (type.isSubtypeOf<Uint8List?>()) {
    final str = raw.toString();
    if (str.isEmpty) {
      return null;
    }

    return Base64Decoder().convert(str) as T;
  }

  if (type.isSubtypeOf<List<String>?>()) {
    if (raw is List) {
      return raw.whereNotNull.map((e) => e.toString()).toList() as T;
    }

    return null;
  }

  if (type.isSubtypeOf<List<double>?>()) {
    if (raw is List) {
      return raw.map((e) => double.tryParse(e.toString())).whereNotNull.toList()
          as T;
    }

    return null;
  }

  if (type.isSubtypeOf<List<int>?>()) {
    if (raw is List) {
      return raw.map((e) => int.tryParse(e.toString())).whereNotNull.toList()
          as T;
    }

    return null;
  }

  if (type.isSubtypeOf<List<num>?>()) {
    if (raw is List) {
      return raw.map((e) => num.tryParse(e.toString())).whereNotNull.toList()
          as T;
    }

    return null;
  }

  throw ApiError.invalidType(T);
}

dynamic encodeTyped<T>(T? value) {
  if (value == null) {
    return null;
  }

  if (T == DateTime) {
    return (value as DateTime).toIso8601String();
  }

  if (T == Uint8List) {
    return Base64Encoder().convert(value as Uint8List);
  }

  if (T == String || T == int || T == double || T == bool) {
    return value;
  }

  throw ApiError.invalidType(T);
}

List<T> decodeList<T>(dynamic raw, T Function(dynamic) decoder) {
  if (raw is List) {
    return raw.whereNotNull.map(decoder).toList();
  } else {
    return [];
  }
}

List encodeList<T>(List<T>? value, dynamic Function(T) encoder) {
  if (value == null) {
    return [];
  }

  return value.map(encoder).toList();
}

Map<String, V> decodeStringMap<V>(dynamic raw, V Function(dynamic) decoder) {
  if (raw is Map<String, dynamic>) {
    return raw.map((key, value) => MapEntry(key, decoder(value)));
  } else {
    return {};
  }
}

Map<String, dynamic> encodeStringMap<V>(
    Map<String, V>? value, dynamic Function(V) encoder) {
  if (value == null) {
    return {};
  }

  return value.map((key, value) => MapEntry(key, encoder(value)));
}

T decodeEnum<T extends Enum>(dynamic raw, List<T> values) {
  if (raw is String) {
    return findEnum(raw, values);
  } else if (raw is T) {
    return raw;
  } else {
    throw ApiError.invalidType(T);
  }
}

T? decodeEnumNullable<T extends Enum>(dynamic raw, List<T> values) {
  if (raw is String) {
    return findEnum(raw, values);
  } else if (raw is T) {
    return raw;
  } else if (raw == null) {
    return null;
  } else {
    throw ApiError.invalidType(T);
  }
}

String encodeJsonString(dynamic value) => JsonEncoder().convert(value);
