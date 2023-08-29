import 'dart:typed_data';

import 'package:dart_amqp/dart_amqp.dart' as amqp;
import 'package:datahub/src/broker/broker_message.dart';

class AmqpBrokerMessage extends BrokerMessage {
  final amqp.AmqpMessage amqpMessage;

  @override
  Uint8List get payload => amqpMessage.payload ?? Uint8List(0);

  AmqpBrokerMessage(this.amqpMessage);

  @override
  void ack() => amqpMessage.ack();

  @override
  void reject({bool requeue = false}) => amqpMessage.reject(requeue);
}
