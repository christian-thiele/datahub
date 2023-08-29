import 'dart:typed_data';

import 'package:dart_amqp/dart_amqp.dart' as amqp;

import 'package:datahub/src/broker/broker_exchange.dart';

import 'amqp_broker_queue.dart';

class AmqpBrokerExchange extends BrokerExchange {
  final amqp.Exchange amqpExchange;

  AmqpBrokerExchange(this.amqpExchange, super.name, super.type);

  @override
  Future<AmqpBrokerQueue> declareAndBindQueue(
    String queueName,
    List<String> topics, {
    bool passive = false,
    bool durable = false,
    bool exclusive = false,
    bool autoDelete = false,
    bool noWait = false,
    bool declare = true,
    Map<String, Object> arguments = const {},
  }) async {
    if (topics.isEmpty && amqpExchange.type != amqp.ExchangeType.TOPIC) {
      topics.add('');
    }

    final queue = AmqpBrokerQueue(
      await amqpExchange.channel.queue(
        queueName,
        passive: passive,
        durable: durable,
        exclusive: exclusive,
        autoDelete: autoDelete,
        noWait: noWait,
        declare: declare,
      ),
      queueName,
    );

    await queue.bind(this, topics);

    return queue;
  }

  @override
  Future<AmqpBrokerQueue> declareAndBindPrivateQueue(
    List<String> topics, {
    bool noWait = false,
    Map<String, Object> arguments = const {},
  }) async {
    if (topics.isEmpty && amqpExchange.type != amqp.ExchangeType.TOPIC) {
      topics.add('');
    }

    final q = await amqpExchange.channel.privateQueue(noWait: noWait);
    final queue = AmqpBrokerQueue(q, q.name);

    await queue.bind(this, topics);

    return queue;
  }

  @override
  Future<void> publish(Uint8List data, String? topic) async {
    amqpExchange.publish(data, topic);
  }
}
