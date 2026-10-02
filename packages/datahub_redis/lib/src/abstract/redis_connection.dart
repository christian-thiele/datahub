import 'redis_commands.dart';
import 'redis_transaction.dart';

/// A single connection to the Redis server, provided by
/// [Redis.useConnection].
///
/// Commands are pipelined: they are written immediately and the replies are
/// matched to the commands in order, so concurrent commands on the same
/// connection need only a single round trip:
///
/// ```dart
/// final [a, b] = await Future.wait([connection.get('a'), connection.get('b')]);
/// ```
///
/// When a command times out, its reply could arrive at any later point and
/// be mistaken for the reply of another command. The connection is closed in
/// that case and all pending commands fail.
abstract interface class RedisConnection implements RedisCommands {
  /// Whether the connection is still open.
  bool get isOpen;

  /// Watches [keys] for modifications, so that the next [transaction] on
  /// this connection is aborted if any of them is modified by another client
  /// before it is executed (optimistic locking).
  ///
  /// The keys are unwatched when the next transaction completes, by
  /// [unwatch] or when the connection is returned to the pool.
  Future<void> watch(Iterable<String> keys);

  /// Forgets all keys watched by [watch].
  Future<void> unwatch();

  /// Executes the commands queued by [commands] atomically.
  ///
  /// Returns false if the transaction was aborted because a key watched with
  /// [watch] was modified, true otherwise. The results of the individual
  /// commands are provided by the futures returned while queueing them, see
  /// [RedisTransaction].
  ///
  /// A typical check-and-set retries until no concurrent modification
  /// happened:
  ///
  /// ```dart
  /// await redis.useConnection((connection) async {
  ///   while (true) {
  ///     await connection.watch(['balance']);
  ///     final balance = int.parse(await connection.get('balance') ?? '0');
  ///     final executed = await connection.transaction((tx) {
  ///       tx.set('balance', balance - 10);
  ///       tx.rpush('history', ['-10']);
  ///     });
  ///     if (executed) break;
  ///   }
  /// });
  /// ```
  ///
  /// Throws a [RedisServerException] (`EXECABORT`) if the server rejected a
  /// command while queueing it, in which case no command is executed.
  Future<bool> transaction(void Function(RedisTransaction tx) commands);

  /// Iterates all keys of the database using `SCAN`, see [Redis.scan].
  Stream<String> scan({String? match, int? count, String? type});
}
