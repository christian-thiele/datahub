import 'redis_commands.dart';
import 'redis_connection.dart';
import 'redis_message.dart';
import 'redis_transaction.dart';

/// Access to a Redis server, provided by [RedisService].
///
/// Every command method takes a connection from the connection pool for the
/// duration of the command. Use [useConnection] to run multiple commands on
/// the same connection, for example to pipeline them or to watch keys for a
/// [RedisConnection.transaction].
///
/// ```dart
/// final redis = Find<Redis>().find();
/// await redis.set('greeting', 'hello', ttl: const Duration(minutes: 5));
/// print(await redis.get('greeting'));
/// ```
abstract interface class Redis implements RedisCommands {
  /// Provides a connection from the connection pool to [delegate].
  ///
  /// The connection is returned to the pool when [delegate] completes.
  /// Command methods of [Redis] that are called by [delegate] use the same
  /// connection instead of taking another one from the pool.
  ///
  /// [timeout] limits the time spent waiting for a pooled connection.
  ///
  /// Connection state that was changed by [delegate] (watched keys, an
  /// unfinished `MULTI` or a different database selected via `SELECT`) is
  /// reset before the connection is returned to the pool.
  Future<T> useConnection<T>(
    Future<T> Function(RedisConnection connection) delegate, {
    Duration? timeout,
  });

  /// Executes the commands queued by [commands] atomically on a pooled
  /// connection.
  ///
  /// See [RedisTransaction] for how results are provided. To make the
  /// transaction depend on values read before, use
  /// [RedisConnection.watch] and [RedisConnection.transaction] inside
  /// [useConnection].
  ///
  /// Returns false if the transaction was aborted because of a watched key,
  /// which can only happen when called inside [useConnection] after keys
  /// were watched on that connection.
  ///
  /// ```dart
  /// late Future<int> visits;
  /// await redis.transaction((tx) {
  ///   visits = tx.incr('visits');
  ///   tx.expire('visits', const Duration(days: 1));
  /// });
  /// print(await visits);
  /// ```
  ///
  /// Throws a [RedisServerException] (`EXECABORT`) if the server rejected a
  /// command while queueing it, in which case no command is executed.
  Future<bool> transaction(void Function(RedisTransaction tx) commands);

  /// Iterates all keys of the database using `SCAN`.
  ///
  /// [match] filters keys by glob-style pattern, [count] is a hint for the
  /// number of keys the server examines per call and [type] filters keys by
  /// value type (`string`, `list`, `set`, `zset`, `hash`, `stream`).
  ///
  /// Keys are fetched lazily, one batch per `SCAN` call. A connection is
  /// only held while a batch is fetched. As guaranteed by `SCAN`, keys that
  /// exist during the whole iteration are returned, but some keys may be
  /// returned more than once.
  Stream<String> scan({String? match, int? count, String? type});

  /// Returns a broadcast stream of the messages published to [channel].
  ///
  /// The channel is subscribed while the stream has listeners. Messages are
  /// received on a dedicated connection outside of the connection pool,
  /// which is health checked and re-established automatically when lost.
  /// Like all Redis Pub/Sub messages, messages published while that
  /// connection is down are not delivered.
  Stream<RedisMessage> subscribe(String channel);

  /// Returns a broadcast stream of the messages published to channels
  /// matching the glob-style [pattern].
  ///
  /// See [subscribe].
  Stream<RedisMessage> psubscribe(String pattern);
}
