import 'dart:typed_data';

import 'package:dart_amqp/dart_amqp.dart' as amqp;
import 'package:datahub/src/broker/broker_message.dart';

class AmqpBrokerMessage extends BrokerMessage {
  final amqp.AmqpMessage amqpMessage;

  @override
  Uint8List get payload => amqpMessage.payload ?? Uint8List(0);

  AmqpBrokerMessage(this.amqpMessage)
      : super(BrokerMessageProperties(
          contentType: amqpMessage.properties?.contentType,
          contentEncoding: amqpMessage.properties?.contentEncoding,
          headers: amqpMessage.properties?.headers ?? {},
          deliveryMode: amqpMessage.properties?.deliveryMode,
          priority: amqpMessage.properties?.priority,
          correlationId: amqpMessage.properties?.corellationId,
          replyTo: amqpMessage.properties?.replyTo,
          expiration: amqpMessage.properties?.expiration,
          messageId: amqpMessage.properties?.messageId,
          timestamp: amqpMessage.properties?.timestamp,
          type: amqpMessage.properties?.type,
          userId: amqpMessage.properties?.userId,
          appId: amqpMessage.properties?.appId,
        ));

  @override
  void ack() => amqpMessage.ack();

  @override
  void reject({bool requeue = false}) => amqpMessage.reject(requeue);
}
