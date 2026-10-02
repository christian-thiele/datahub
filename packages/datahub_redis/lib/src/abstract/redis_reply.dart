import 'dart:convert';
import 'dart:typed_data';

import 'redis_exception.dart';

/// A reply of the Redis server (RESP2).
///
/// Use pattern matching on the subclasses or one of the conversion getters
/// ([asString], [asInt], [asDouble], [asBytes], [asList]). The conversion
/// getters return null for [RedisNull] and throw a [RedisException] when the
/// reply cannot be represented as the requested type. Reading a
/// [RedisErrorReply] through a conversion getter throws the corresponding
/// [RedisServerException].
sealed class RedisReply {
  const RedisReply();

  /// Whether this is a null reply (null bulk string or null array).
  bool get isNull => this is RedisNull;

  /// The reply as text.
  ///
  /// Bulk strings are decoded as UTF-8 and throw a [FormatException] when
  /// they contain malformed UTF-8. Use [asBytes] for binary data.
  String? get asString => switch (this) {
    RedisSimpleString(:final value) => value,
    RedisBulkString(:final bytes) => utf8.decode(bytes),
    RedisInteger(:final value) => value.toString(),
    RedisNull() => null,
    RedisErrorReply(:final message) => throw RedisServerException(message),
    RedisArray() => throw _unexpected('string'),
  };

  /// The reply as integer, parsing string replies if necessary.
  int? get asInt => switch (this) {
    RedisInteger(:final value) => value,
    RedisSimpleString() || RedisBulkString() =>
      int.tryParse(asString!) ?? (throw _unexpected('integer')),
    RedisNull() => null,
    RedisErrorReply(:final message) => throw RedisServerException(message),
    RedisArray() => throw _unexpected('integer'),
  };

  /// The reply as floating point number, parsing string replies if
  /// necessary.
  ///
  /// Understands the `inf` / `-inf` notation Redis uses for infinite values.
  double? get asDouble => switch (this) {
    RedisInteger(:final value) => value.toDouble(),
    RedisSimpleString() || RedisBulkString() =>
      parseRedisDouble(asString!) ?? (throw _unexpected('double')),
    RedisNull() => null,
    RedisErrorReply(:final message) => throw RedisServerException(message),
    RedisArray() => throw _unexpected('double'),
  };

  /// The reply as raw bytes.
  Uint8List? get asBytes => switch (this) {
    RedisBulkString(:final bytes) => bytes,
    RedisSimpleString(:final value) => utf8.encode(value),
    RedisInteger(:final value) => ascii.encode(value.toString()),
    RedisNull() => null,
    RedisErrorReply(:final message) => throw RedisServerException(message),
    RedisArray() => throw _unexpected('bytes'),
  };

  /// The elements of an array reply.
  List<RedisReply>? get asList => switch (this) {
    RedisArray(:final items) => items,
    RedisNull() => null,
    RedisErrorReply(:final message) => throw RedisServerException(message),
    _ => throw _unexpected('array'),
  };

  RedisException _unexpected(String expected) =>
      RedisException('Expected $expected reply, got $this.');
}

/// A status reply like `OK` or `PONG`.
final class RedisSimpleString extends RedisReply {
  final String value;

  const RedisSimpleString(this.value);

  @override
  bool operator ==(Object other) =>
      other is RedisSimpleString && other.value == value;

  @override
  int get hashCode => Object.hash(RedisSimpleString, value);

  @override
  String toString() => 'RedisSimpleString($value)';
}

/// An error reply.
///
/// Error replies are thrown as [RedisServerException] by command methods.
/// They only appear as values inside arrays, for example in the results of a
/// transaction.
final class RedisErrorReply extends RedisReply {
  final String message;

  const RedisErrorReply(this.message);

  RedisServerException toException() => RedisServerException(message);

  @override
  bool operator ==(Object other) =>
      other is RedisErrorReply && other.message == message;

  @override
  int get hashCode => Object.hash(RedisErrorReply, message);

  @override
  String toString() => 'RedisErrorReply($message)';
}

/// A signed 64 bit integer reply.
final class RedisInteger extends RedisReply {
  final int value;

  const RedisInteger(this.value);

  @override
  bool operator ==(Object other) =>
      other is RedisInteger && other.value == value;

  @override
  int get hashCode => Object.hash(RedisInteger, value);

  @override
  String toString() => 'RedisInteger($value)';
}

/// A binary safe string reply.
final class RedisBulkString extends RedisReply {
  final Uint8List bytes;

  const RedisBulkString(this.bytes);

  RedisBulkString.fromString(String value) : bytes = utf8.encode(value);

  @override
  bool operator ==(Object other) {
    if (other is! RedisBulkString || other.bytes.length != bytes.length) {
      return false;
    }
    for (var i = 0; i < bytes.length; i++) {
      if (other.bytes[i] != bytes[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(RedisBulkString, Object.hashAll(bytes));

  @override
  String toString() =>
      'RedisBulkString(${utf8.decode(bytes, allowMalformed: true)})';
}

/// An array reply.
final class RedisArray extends RedisReply {
  final List<RedisReply> items;

  const RedisArray(this.items);

  @override
  bool operator ==(Object other) {
    if (other is! RedisArray || other.items.length != items.length) {
      return false;
    }
    for (var i = 0; i < items.length; i++) {
      if (other.items[i] != items[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(RedisArray, Object.hashAll(items));

  @override
  String toString() => 'RedisArray(${items.join(', ')})';
}

/// A null reply, which RESP2 sends as null bulk string or null array.
final class RedisNull extends RedisReply {
  const RedisNull();

  @override
  bool operator ==(Object other) => other is RedisNull;

  @override
  int get hashCode => (RedisNull).hashCode;

  @override
  String toString() => 'RedisNull()';
}

/// Parses a floating point number as formatted by Redis.
///
/// Returns null if [value] is not a number.
double? parseRedisDouble(String value) => switch (value.toLowerCase()) {
  'inf' || '+inf' || 'infinity' || '+infinity' => double.infinity,
  '-inf' || '-infinity' => double.negativeInfinity,
  'nan' => double.nan,
  _ => double.tryParse(value),
};
