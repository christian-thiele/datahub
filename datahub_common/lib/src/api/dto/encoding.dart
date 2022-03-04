import 'dart:convert';
import 'dart:typed_data';
import 'package:boost/boost.dart';

import 'package:cl_datahub_common/common.dart';

T decodeTyped<T>(dynamic raw) {
  return decodeTypedNullable(raw) ?? (throw ApiException('Missing value.'));
}

T? decodeTypedNullable<T>(dynamic raw) {
  if (raw == null) {
    return null;
  }

  if (raw is T) {
    return raw;
  }

  if (T == String) {
    return raw.toString() as T;
  }

  if (T == int) {
    return int.tryParse(raw.toString()) as T;
  }

  if (T == double) {
    return double.tryParse(raw.toString()) as T;
  }

  if (T == bool) {
    if (raw is num) {
      return raw > 0 as T;
    }

    return (raw.toString().toLowerCase() == 'true') as T;
  }

  if (T == DateTime) {
    return DateTime.tryParse(raw.toString()) as T;
  }

  if (T == Uint8List) {
    return Base64Decoder().convert(raw.toString()) as T;
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

T decodeEnum<T>(dynamic raw, List<T> values) {
  if (raw is String) {
    return findEnum(raw, values);
  } else if (raw is T) {
    return raw;
  } else {
    throw ApiError.invalidType(T);
  }
}

T? decodeEnumNullable<T>(dynamic raw, List<T> values) {
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

String encodeEnum<T>(T value) => enumName<T>(value);

String? encodeEnumNullable<T>(T? value) {
  if (value == null) {
    return null;
  }

  return enumName<T>(value);
}
