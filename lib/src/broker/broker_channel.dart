import 'broker_exchange.dart';

/// Interface for a single channel to a message broker.
abstract class BrokerChannel {
  Future<BrokerExchange> declareExchange(String name, BrokerExchangeType type);

  Future<void> close();
}
