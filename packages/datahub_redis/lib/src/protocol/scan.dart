import '../abstract/redis_commands.dart';
import '../abstract/redis_exception.dart';
import '../abstract/redis_reply.dart';

/// Iterates the keys of the database by running `SCAN` on [commands]
/// lazily, one batch per listener demand.
Stream<String> scanKeys(
  RedisCommands commands, {
  String? match,
  int? count,
  String? type,
}) async* {
  var cursor = '0';
  do {
    final reply = await commands.execute([
      'SCAN',
      cursor,
      if (match != null) ...['MATCH', match],
      if (count != null) ...['COUNT', count],
      if (type != null) ...['TYPE', type],
    ]);

    switch (reply) {
      case RedisArray(items: [final next, RedisArray(items: final keys)]):
        cursor = next.asString!;
        for (final key in keys) {
          yield key.asString!;
        }
      default:
        throw RedisException('Unexpected reply to SCAN: $reply');
    }
  } while (cursor != '0');
}
