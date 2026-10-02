import 'dart:async';
import 'dart:typed_data';

import 'redis_exception.dart';
import 'redis_reply.dart';
import 'redis_script.dart';

/// Typed methods for common Redis commands.
///
/// Every method is a thin wrapper around [sendCommand]. Commands without a
/// typed method can be sent with [execute].
///
/// Values written to Redis (`Object value` parameters) can be a [String]
/// (stored as UTF-8), an [int], a [double] or a [List<int>] / [Uint8List]
/// (stored as raw bytes). Methods returning text decode values as UTF-8;
/// use [getBytes] or [execute] for binary data.
///
/// Server errors are thrown as [RedisServerException], connection failures
/// as [RedisConnectionException] and exceeded command timeouts as
/// [TimeoutException].
mixin RedisCommands {
  /// Sends [command] and converts the reply using [decode].
  ///
  /// This is the primitive all other methods are built on, and the
  /// recommended way of adding typed methods for further commands (for
  /// example as extension on [RedisCommands]), since it works the same way
  /// on pooled access, single connections and transactions.
  ///
  /// Error replies are thrown as [RedisServerException] and never passed to
  /// [decode]. [timeout] overrides the configured command timeout.
  Future<T> sendCommand<T>(
    List<Object> command,
    T Function(RedisReply reply) decode, {
    Duration? timeout,
  });

  /// Sends [command] and returns the raw reply.
  ///
  /// The first element is the command name, followed by its arguments:
  ///
  /// ```dart
  /// final reply = await redis.execute(['OBJECT', 'ENCODING', 'key']);
  /// print(reply.asString);
  /// ```
  ///
  /// Commands that change the protocol state of a connection (`SUBSCRIBE`,
  /// `MONITOR`, `HELLO`, `RESET`, `QUIT`, `CLIENT REPLY`, ...) are rejected
  /// with an [UnsupportedError]. Use [Redis.subscribe] for Pub/Sub.
  Future<RedisReply> execute(List<Object> command, {Duration? timeout}) =>
      sendCommand(command, _reply, timeout: timeout);

  /// Pings the server and returns its reply, usually `PONG`.
  Future<String> ping() => sendCommand(['PING'], _string);

  // --- keys ---

  /// Deletes [keys] and returns the number of keys that were removed.
  Future<int> del(Iterable<String> keys) => sendCommand(['DEL', ...keys], _int);

  /// Deletes [keys] like [del], but reclaims memory in the background.
  Future<int> unlink(Iterable<String> keys) =>
      sendCommand(['UNLINK', ...keys], _int);

  /// Whether [key] exists.
  Future<bool> exists(String key) => sendCommand(['EXISTS', key], _bool);

  /// Sets a time to live of [ttl] (millisecond precision) on [key].
  ///
  /// Returns false if the key does not exist.
  Future<bool> expire(String key, Duration ttl) =>
      sendCommand(['PEXPIRE', key, ttl.inMilliseconds], _bool);

  /// Removes the time to live of [key].
  ///
  /// Returns false if the key does not exist or has no time to live.
  Future<bool> persist(String key) => sendCommand(['PERSIST', key], _bool);

  /// The remaining time to live of [key].
  ///
  /// Returns null if the key does not exist or has no time to live.
  Future<Duration?> ttl(String key) => sendCommand(['PTTL', key], (reply) {
    final milliseconds = _int(reply);
    return milliseconds < 0 ? null : Duration(milliseconds: milliseconds);
  });

  // --- strings ---

  /// The value of [key] as text, or null if the key does not exist.
  Future<String?> get(String key) => sendCommand(['GET', key], _stringOrNull);

  /// The value of [key] as raw bytes, or null if the key does not exist.
  Future<Uint8List?> getBytes(String key) =>
      sendCommand(['GET', key], _bytesOrNull);

  /// Sets [key] to [value].
  ///
  /// When [ttl] is set, the key expires after that time (millisecond
  /// precision). With [ifAbsent] the key is only set if it does not exist
  /// yet (`NX`), with [ifExists] only if it already exists (`XX`).
  ///
  /// Returns false if the value was not set because of [ifAbsent] or
  /// [ifExists].
  Future<bool> set(
    String key,
    Object value, {
    Duration? ttl,
    bool ifAbsent = false,
    bool ifExists = false,
  }) {
    if (ifAbsent && ifExists) {
      throw ArgumentError('ifAbsent and ifExists are mutually exclusive.');
    }
    return sendCommand([
      'SET',
      key,
      value,
      if (ttl != null) ...['PX', ttl.inMilliseconds],
      if (ifAbsent) 'NX',
      if (ifExists) 'XX',
    ], (reply) => !reply.isNull);
  }

  /// Returns the value of [key] as text and deletes the key.
  Future<String?> getdel(String key) =>
      sendCommand(['GETDEL', key], _stringOrNull);

  /// The values of [keys] in the same order, null for missing keys.
  Future<List<String?>> mget(Iterable<String> keys) =>
      sendCommand(['MGET', ...keys], _stringOrNullList);

  /// Sets all keys of [values] at once.
  Future<void> mset(Map<String, Object> values) => sendCommand([
    'MSET',
    for (final MapEntry(:key, :value) in values.entries) ...[key, value],
  ], _void);

  /// Increments the integer value of [key] by one and returns the result.
  ///
  /// A missing key counts as zero.
  Future<int> incr(String key) => sendCommand(['INCR', key], _int);

  /// Increments the integer value of [key] by [increment] and returns the
  /// result.
  Future<int> incrby(String key, int increment) =>
      sendCommand(['INCRBY', key, increment], _int);

  /// Increments the floating point value of [key] by [increment] and returns
  /// the result.
  Future<double> incrbyfloat(String key, double increment) =>
      sendCommand(['INCRBYFLOAT', key, increment], _double);

  /// Decrements the integer value of [key] by one and returns the result.
  Future<int> decr(String key) => sendCommand(['DECR', key], _int);

  /// Decrements the integer value of [key] by [decrement] and returns the
  /// result.
  Future<int> decrby(String key, int decrement) =>
      sendCommand(['DECRBY', key, decrement], _int);

  // --- hashes ---

  /// The value of [field] in hash [key], or null if it does not exist.
  Future<String?> hget(String key, String field) =>
      sendCommand(['HGET', key, field], _stringOrNull);

  /// The values of [fields] in hash [key], null for missing fields.
  Future<List<String?>> hmget(String key, Iterable<String> fields) =>
      sendCommand(['HMGET', key, ...fields], _stringOrNullList);

  /// All fields and values of hash [key].
  Future<Map<String, String>> hgetall(String key) =>
      sendCommand(['HGETALL', key], (reply) {
        final items = _list(reply);
        return {
          for (var i = 0; i + 1 < items.length; i += 2)
            items[i].asString!: items[i + 1].asString!,
        };
      });

  /// Sets [fields] in hash [key] and returns the number of fields that were
  /// added (not counting updated fields).
  Future<int> hset(String key, Map<String, Object> fields) => sendCommand([
    'HSET',
    key,
    for (final MapEntry(:key, :value) in fields.entries) ...[key, value],
  ], _int);

  /// Deletes [fields] from hash [key] and returns the number of removed
  /// fields.
  Future<int> hdel(String key, Iterable<String> fields) =>
      sendCommand(['HDEL', key, ...fields], _int);

  /// Whether [field] exists in hash [key].
  Future<bool> hexists(String key, String field) =>
      sendCommand(['HEXISTS', key, field], _bool);

  /// Increments the integer value of [field] in hash [key] by [increment]
  /// and returns the result.
  Future<int> hincrby(String key, String field, int increment) =>
      sendCommand(['HINCRBY', key, field, increment], _int);

  /// The number of fields in hash [key].
  Future<int> hlen(String key) => sendCommand(['HLEN', key], _int);

  // --- lists ---

  /// Prepends [values] to list [key] and returns the new length.
  Future<int> lpush(String key, Iterable<Object> values) =>
      sendCommand(['LPUSH', key, ...values], _int);

  /// Appends [values] to list [key] and returns the new length.
  Future<int> rpush(String key, Iterable<Object> values) =>
      sendCommand(['RPUSH', key, ...values], _int);

  /// Removes and returns the first element of list [key].
  Future<String?> lpop(String key) => sendCommand(['LPOP', key], _stringOrNull);

  /// Removes and returns the last element of list [key].
  Future<String?> rpop(String key) => sendCommand(['RPOP', key], _stringOrNull);

  /// The elements of list [key] from index [start] to [stop] (inclusive).
  ///
  /// Negative indices count from the end, `lrange(key, 0, -1)` returns the
  /// whole list.
  Future<List<String>> lrange(String key, int start, int stop) =>
      sendCommand(['LRANGE', key, start, stop], _stringList);

  /// Trims list [key] to the elements from index [start] to [stop]
  /// (inclusive).
  Future<void> ltrim(String key, int start, int stop) =>
      sendCommand(['LTRIM', key, start, stop], _void);

  /// The length of list [key].
  Future<int> llen(String key) => sendCommand(['LLEN', key], _int);

  // --- sets ---

  /// Adds [members] to set [key] and returns the number of added members.
  Future<int> sadd(String key, Iterable<Object> members) =>
      sendCommand(['SADD', key, ...members], _int);

  /// Removes [members] from set [key] and returns the number of removed
  /// members.
  Future<int> srem(String key, Iterable<Object> members) =>
      sendCommand(['SREM', key, ...members], _int);

  /// All members of set [key].
  Future<Set<String>> smembers(String key) =>
      sendCommand(['SMEMBERS', key], (reply) => _stringList(reply).toSet());

  /// Whether [member] is part of set [key].
  Future<bool> sismember(String key, Object member) =>
      sendCommand(['SISMEMBER', key, member], _bool);

  /// The number of members of set [key].
  Future<int> scard(String key) => sendCommand(['SCARD', key], _int);

  // --- sorted sets ---

  /// Adds [members] with their scores to sorted set [key], or updates the
  /// scores of existing members.
  ///
  /// Returns the number of added members.
  Future<int> zadd(String key, Map<String, double> members) => sendCommand([
    'ZADD',
    key,
    for (final MapEntry(:key, :value) in members.entries) ...[value, key],
  ], _int);

  /// Removes [members] from sorted set [key] and returns the number of
  /// removed members.
  Future<int> zrem(String key, Iterable<String> members) =>
      sendCommand(['ZREM', key, ...members], _int);

  /// The score of [member] in sorted set [key], or null if it is not a
  /// member.
  Future<double?> zscore(String key, String member) =>
      sendCommand(['ZSCORE', key, member], (reply) => reply.asDouble);

  /// Increments the score of [member] in sorted set [key] by [increment] and
  /// returns the new score.
  Future<double> zincrby(String key, double increment, String member) =>
      sendCommand(['ZINCRBY', key, increment, member], _double);

  /// The members of sorted set [key] from rank [start] to [stop] (inclusive)
  /// ordered by ascending score.
  ///
  /// Negative ranks count from the end.
  Future<List<String>> zrange(String key, int start, int stop) =>
      sendCommand(['ZRANGE', key, start, stop], _stringList);

  /// The number of members of sorted set [key].
  Future<int> zcard(String key) => sendCommand(['ZCARD', key], _int);

  // --- pub/sub ---

  /// Publishes [message] to [channel] and returns the number of clients
  /// that received it.
  Future<int> publish(String channel, Object message) =>
      sendCommand(['PUBLISH', channel, message], _int);

  // --- scripting ---

  /// Runs [script] with [keys] and [args] and returns its result.
  ///
  /// The script is invoked via `EVALSHA` and only sent to the server when it
  /// is not cached there (`NOSCRIPT`).
  Future<RedisReply> eval(
    RedisScript script, {
    List<String> keys = const [],
    List<Object> args = const [],
  }) async {
    try {
      return await execute([
        'EVALSHA',
        script.sha1Digest,
        keys.length,
        ...keys,
        ...args,
      ]);
    } on RedisServerException catch (e) {
      if (e.code != 'NOSCRIPT') {
        rethrow;
      }
      return await execute([
        'EVAL',
        script.source,
        keys.length,
        ...keys,
        ...args,
      ]);
    }
  }
}

RedisReply _reply(RedisReply reply) => reply;

void _void(RedisReply reply) {}

String _string(RedisReply reply) => reply.asString ?? (throw _null(reply));

String? _stringOrNull(RedisReply reply) => reply.asString;

Uint8List? _bytesOrNull(RedisReply reply) => reply.asBytes;

int _int(RedisReply reply) => reply.asInt ?? (throw _null(reply));

bool _bool(RedisReply reply) => _int(reply) == 1;

double _double(RedisReply reply) => reply.asDouble ?? (throw _null(reply));

List<RedisReply> _list(RedisReply reply) =>
    reply.asList ?? (throw _null(reply));

List<String> _stringList(RedisReply reply) => [
  for (final item in _list(reply)) _string(item),
];

List<String?> _stringOrNullList(RedisReply reply) => [
  for (final item in _list(reply)) item.asString,
];

RedisException _null(RedisReply reply) =>
    RedisException('Unexpected null reply.');
