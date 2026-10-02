import 'dart:convert';

import 'package:crypto/crypto.dart';

/// A Lua script for [RedisCommands.eval].
///
/// Scripts are executed via `EVALSHA`, so the script source is only sent
/// to the server when it is not cached there yet. Declare scripts as
/// constants to compute the digest only once:
///
/// ```dart
/// const incrementIfExists = RedisScript('''
///   if redis.call('exists', KEYS[1]) == 1 then
///     return redis.call('incr', KEYS[1])
///   end
///   return nil
/// ''');
/// ```
class RedisScript {
  static final _digests = Expando<String>();

  /// The Lua source code of the script.
  final String source;

  const RedisScript(this.source);

  /// The SHA1 digest that identifies the script on the server.
  String get sha1Digest =>
      _digests[this] ??= sha1.convert(utf8.encode(source)).toString();

  @override
  bool operator ==(Object other) =>
      other is RedisScript && other.source == source;

  @override
  int get hashCode => source.hashCode;

  @override
  String toString() => 'RedisScript($sha1Digest)';
}
