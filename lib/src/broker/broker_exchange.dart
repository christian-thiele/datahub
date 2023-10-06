import 'dart:typed_data';

import 'broker_queue.dart';

enum BrokerExchangeType { topic, fanOut, direct }

abstract class BrokerExchange {
  final String name;
  final BrokerExchangeType type;

  BrokerExchange(this.name, this.type);

  Future<void> publish(Uint8List data, String? topic);

  Future<BrokerQueue> declareAndBindQueue(
    String queueName,
    List<String> topics,
  );

  Future<BrokerQueue> declareAndBindPrivateQueue(List<String> topics);
}
