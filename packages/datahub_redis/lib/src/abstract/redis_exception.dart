import 'dart:io';

/// Base class of all exceptions thrown by datahub_redis.
class RedisException implements Exception {
  final String message;

  const RedisException(this.message);

  @override
  String toString() => 'RedisException: $message';
}

/// The Redis server replied to a command with an error.
///
/// The connection is still usable after a server error.
class RedisServerException extends RedisException {
  const RedisServerException(super.message);

  /// The error prefix, which is the first word of the error message.
  ///
  /// For example `ERR`, `WRONGTYPE`, `NOSCRIPT`, `WRONGPASS` or `EXECABORT`.
  String get code {
    final space = message.indexOf(' ');
    return space == -1 ? message : message.substring(0, space);
  }

  @override
  String toString() => 'RedisServerException: $message';
}

/// The connection to the Redis server could not be established, was lost or
/// had to be closed because of a protocol violation.
///
/// Commands that were in flight on that connection may or may not have been
/// executed by the server.
class RedisConnectionException extends RedisException implements IOException {
  /// The underlying error, if any.
  final Object? cause;

  const RedisConnectionException(super.message, [this.cause]);

  @override
  String toString() => cause == null
      ? 'RedisConnectionException: $message'
      : 'RedisConnectionException: $message ($cause)';
}

/// A transaction was not executed because at least one of the watched keys
/// was modified after `WATCH`.
class RedisTransactionAbortedException extends RedisException {
  const RedisTransactionAbortedException()
    : super('Transaction aborted because a watched key was modified.');

  @override
  String toString() => 'RedisTransactionAbortedException: $message';
}
