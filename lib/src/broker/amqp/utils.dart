import 'package:dart_amqp/dart_amqp.dart';
import 'package:datahub/src/broker/broker_exchange.dart';

extension ExchangeTypeMapper on BrokerExchangeType {
  ExchangeType toAmqp() {
    switch (this) {
      case BrokerExchangeType.topic:
        return ExchangeType.TOPIC;
      case BrokerExchangeType.fanOut:
        return ExchangeType.FANOUT;
      case BrokerExchangeType.direct:
        return ExchangeType.DIRECT;
    }
  }
}
