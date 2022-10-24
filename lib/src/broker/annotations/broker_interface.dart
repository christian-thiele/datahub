/// Annotation for Broker API interface contracts.

@deprecated
class BrokerInterface {
  final String queueName;
  final bool durable;
  final Type? brokerService;
  const BrokerInterface({
    required this.queueName,
    this.durable = true,
    this.brokerService,
  });
}
