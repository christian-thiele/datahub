import 'dart:convert';
import 'dart:typed_data';

import 'package:cl_datahub_common/common.dart';

//TODO check if this todo is still valid later: this is api specific, should be somewhere in api classes to avoid confusion with persistence usage
T? decodeTyped<T>(dynamic raw, {DTOFactory? factory}) {
  if (raw == null) {
    return null;
  }

  if (factory != null) {
    final result = factory(raw);
    if (result is! T) {
      throw ApiError('Factory returned wrong type: $result (should be $T)');
    }

    return result;
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

//TODO check if this todo is still valid later: this is api specific, should be somewhere in api classes to avoid confusion with persistence usage
dynamic encodeTyped<T>(T value) {
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
