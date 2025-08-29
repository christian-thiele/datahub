import 'package:boost/boost.dart';

import 'package:datahub/utils.dart';

/// Decodes a typed value from its transfer representation. (JSON)
///
/// [codec] can be used to override the default codec for type [T].
/// [name] is used in error messages for debugging purposes.
T decodeTyped<T>(dynamic raw, {TransferCodec<T>? codec, String? name}) {
  if (raw is T) {
    return raw;
  }

  if (raw == null) {
    throw CodecException.typeMismatch(T, raw.runtimeType, name);
  }

  codec ??= TransferCodec.find<T>();
  if (codec != null) {
    return (codec as dynamic).decode(raw, name: name) as T;
  }

  throw ApiError.invalidType(T);
}

/// Encodes a typed value to its transfer representation. (JSON)
///
/// [codec] can be used to override the default codec for type [T].
/// [name] is used in error messages for debugging purposes.
dynamic encodeTyped<T>(T value, {TransferCodec<T>? codec}) {
  if (value == null) {
    if (!TypeCheck<T>().isNullable) {
      // this should not be possible
      throw CodecException.typeMismatch(T, value.runtimeType, null);
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

T decodeListTyped<T extends List<E>?, E>(dynamic raw, {String? name}) {
  if (raw is T) {
    return raw;
  } else if (raw is List) {
    final codec = TransferCodec.find<E>();
    return decodeList<T, E>(
        raw, (e, n) => decodeTyped<E>(e, codec: codec, name: n),
        name: name);
  } else if (TypeCheck<T>().isNullable && raw == null) {
    return null as T;
  } else if (raw is List && raw.isEmpty) {
    return <E>[] as T;
  } else {
    throw CodecException.typeMismatch(T, raw.runtimeType, name);
  }
}

T decodeList<T extends List<E>?, E>(
    dynamic raw, E Function(dynamic, String?) decode,
    {String? name}) {
  if (raw is List) {
    return raw.mapIndexed((e, i) => decode(e, '$name[$i]')).toList() as T;
  } else if (TypeCheck<T>().isNullable && raw == null) {
    return raw?.map(decode).toList() as T;
  } else {
    throw CodecException.typeMismatch(T, raw.runtimeType, name);
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

T decodeMapTyped<T extends Map<String, V>?, V>(dynamic raw, {String? name}) {
  if (raw is T) {
    return raw;
  } else if (raw is Map<String, dynamic>) {
    final codec = TransferCodec.find<V>();
    return raw.map((key, value) => MapEntry(
        key,
        decodeTyped<V>(value,
            codec: codec, name: name?.apply((n) => '$n.$key')))) as T;
  } else if (TypeCheck<T>().isNullable && raw == null) {
    return null as T;
  } else if (raw is Map && raw.isEmpty) {
    return <String, V>{} as T;
  } else {
    throw CodecException.typeMismatch(T, raw.runtimeType, name);
  }
}

T decodeMap<T extends Map<String, V>?, V>(
    dynamic raw, V Function(dynamic, String?) decode,
    {String? name}) {
  if (raw is Map<String, dynamic>) {
    return raw.map((key, value) =>
        MapEntry(key, decode(value, name?.apply((n) => '$n.$key')))) as T;
  } else if (TypeCheck<T>().isNullable && raw == null) {
    return null as T;
  } else {
    throw CodecException.typeMismatch(T, raw.runtimeType, name);
  }
}

T decodeEnum<T extends Enum>(dynamic raw, List<T> values, {String? name}) {
  if (raw is String) {
    return findEnum(raw, values);
  } else if (raw is T) {
    return raw;
  } else {
    throw CodecException.typeMismatch(T, raw.runtimeType, name);
  }
}

T? decodeEnumNullable<T extends Enum>(dynamic raw, List<T> values,
    {String? name}) {
  if (raw is String) {
    return findEnum(raw, values);
  } else if (raw is T) {
    return raw;
  } else if (raw == null) {
    return null;
  } else {
    throw CodecException.typeMismatch(T, raw.runtimeType, name);
  }
}
