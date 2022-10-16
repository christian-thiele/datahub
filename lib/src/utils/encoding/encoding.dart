import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/utils.dart';

T decodeTyped<T>(dynamic raw, {TransferCodec<T>? codec}) {
  if (raw is T) {
    return raw;
  }

  if (raw == null) {
    throw CodecException.typeMismatch(T, raw.runtimeType);
  }

  codec ??= TransferCodec.find<T>();
  if (codec != null) {
    return (codec as dynamic).decode(raw) as T;
  }

  throw ApiError.invalidType(T);
}

dynamic encodeTyped<T>(T value, {TransferCodec<T>? codec}) {
  if (value == null) {
    if (!TypeCheck<T>().isNullable) {
      throw CodecException.typeMismatch(T, value.runtimeType);
    }

    return null;
  }

  codec ??= TransferCodec.find<T>();
  if (codec != null) {
    return (codec as dynamic).encode(value);
  }

  throw ApiError.invalidType(T);
}

dynamic encodeListTyped<T extends List<E>?, E>(T value) {
  final codec = TransferCodec.find<E>();
  return encodeList(value, (e) => encodeTyped(e, codec: codec));
}

dynamic encodeList<T extends List<E>?, E>(T value, dynamic Function(E) encode) {
  return value?.map(encode).toList();
}

T decodeListTyped<T extends List<E>?, E>(dynamic raw) {
  if (raw is T) {
    return raw;
  } else if (raw is List) {
    final codec = TransferCodec.find<E>();
    return decodeList<T, E>(raw, (e) => decodeTyped<E>(e, codec: codec));
  } else if (TypeCheck<T>().isNullable && raw == null) {
    return null as T;
  } else if (raw is List && raw.isEmpty) {
    return <E>[] as T;
  } else {
    throw CodecException.typeMismatch(T, raw.runtimeType);
  }
}

T decodeList<T extends List<E>?, E>(dynamic raw, E Function(dynamic) decode) {
  if (raw is List) {
    return raw.map(decode).toList() as T;
  } else if (TypeCheck<T>().isNullable && raw == null) {
    return raw?.map(decode).toList() as T;
  } else {
    throw CodecException.typeMismatch(T, raw.runtimeType);
  }
}

dynamic encodeMapTyped<T extends Map<String, V>?, V>(T value) {
  if (TypeCheck<dynamic>().isSubtypeOf<V>()) {
    return value;
  }

  final codec = TransferCodec.find<V>();
  return encodeMap<T, V>(value, (e) => encodeTyped<V>(e, codec: codec));
}

dynamic encodeMap<T extends Map<String, V>?, V>(
    T value, dynamic Function(V) encode) {
  return value?.map((key, value) => MapEntry(key, encode(value)));
}

T decodeMapTyped<T extends Map<String, V>?, V>(dynamic raw) {
  if (raw is T) {
    return raw;
  } else if (raw is Map<String, dynamic>) {
    final codec = TransferCodec.find<V>();
    return raw.map(
            (key, value) => MapEntry(key, decodeTyped<V>(value, codec: codec)))
        as T;
  } else if (TypeCheck<T>().isNullable && raw == null) {
    return null as T;
  } else if (raw is Map && raw.isEmpty) {
    return <String, V>{} as T;
  } else {
    throw CodecException.typeMismatch(T, raw.runtimeType);
  }
}

T decodeMap<T extends Map<String, V>?, V>(
    dynamic raw, V Function(dynamic) decode) {
  if (raw is Map<String, dynamic>) {
    return raw.map((key, value) => MapEntry(key, decode(value))) as T;
  } else if (TypeCheck<T>().isNullable && raw == null) {
    return null as T;
  } else {
    throw CodecException.typeMismatch(T, raw.runtimeType);
  }
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
