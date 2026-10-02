import 'dart:convert';
import 'dart:typed_data';

/// A message received through Redis Pub/Sub.
class RedisMessage {
  /// The channel the message was published to.
  final String channel;

  /// The pattern that matched [channel], for messages received through a
  /// pattern subscription.
  final String? pattern;

  /// The raw message payload.
  final Uint8List data;

  RedisMessage(this.channel, this.data, {this.pattern});

  /// The message payload decoded as UTF-8.
  ///
  /// Malformed UTF-8 sequences are replaced with U+FFFD; use [data] for binary
  /// payloads.
  late final String payload = utf8.decode(data, allowMalformed: true);

  @override
  String toString() => pattern == null
      ? 'RedisMessage($channel: $payload)'
      : 'RedisMessage($pattern → $channel: $payload)';
}
