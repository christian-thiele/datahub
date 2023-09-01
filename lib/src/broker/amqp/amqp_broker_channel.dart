import 'package:dart_amqp/dart_amqp.dart' as amqp;

import '../broker_exchange.dart';
import '../broker_channel.dart';

import 'amqp_broker_exchange.dart';
import 'utils.dart';

class AmqpBrokerChannel extends BrokerChannel {
  final amqp.Channel amqpChannel;

  AmqpBrokerChannel(this.amqpChannel);

  @override
  Future<BrokerExchange> declareExchange(
      String name, BrokerExchangeType type) async {
    final exchange = await amqpChannel.exchange(name, type.toAmqp());
    return AmqpBrokerExchange(exchange, name, type);
  }

  @override
  Future<void> close() async {
    await amqpChannel.close();
  }
}
