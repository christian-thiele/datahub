import 'redis_commands.dart';

/// Collects commands for a transaction (`MULTI` / `EXEC`).
///
/// Provided by [Redis.transaction] and [RedisConnection.transaction]. All
/// commands are queued while the transaction callback runs, then sent in a
/// single round trip and executed atomically by the server.
///
/// The futures returned by the command methods complete after the
/// transaction was executed:
///
/// * with the command's result if the transaction was executed,
/// * with a [RedisServerException] if this command failed (Redis does not
///   roll back the other commands of a transaction),
/// * with a [RedisTransactionAbortedException] if a watched key was modified,
/// * with the error that prevented the transaction from being executed
///   otherwise.
///
/// Errors of these futures are never reported as unhandled, so results that
/// are not needed can simply be ignored.
///
/// Commands cannot be added after the callback returned, so awaiting inside
/// the callback (for example the result of a queued command) does not work.
/// Read values before starting the transaction, using `WATCH` to detect
/// concurrent modifications (see [RedisConnection.watch]).
abstract interface class RedisTransaction implements RedisCommands {}
