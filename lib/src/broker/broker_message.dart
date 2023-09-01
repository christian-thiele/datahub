//TODO maybe not abstract
//TODO docs
import 'dart:typed_data';

abstract class BrokerMessage {
  final BrokerMessageProperties properties;

  BrokerMessage(this.properties);

  Uint8List get payload;

  void ack();

  void reject({bool requeue = false});
}

class BrokerMessageProperties {
  final String? contentType;
  final String? contentEncoding;
  final Map<String, dynamic> headers;
  final int? deliveryMode;
  final int? priority;
  final String? correlationId;
  final String? replyTo;
  final String? expiration;
  final String? messageId;
  final DateTime? timestamp;
  final String? type;
  final String? userId;
  final String? appId;

  BrokerMessageProperties({
    required this.contentType,
    required this.contentEncoding,
    required this.headers,
    required this.deliveryMode,
    required this.priority,
    required this.correlationId,
    required this.replyTo,
    required this.expiration,
    required this.messageId,
    required this.timestamp,
    required this.type,
    required this.userId,
    required this.appId,
  });
}
