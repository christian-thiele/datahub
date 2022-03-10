/// Annotation for Broker API interface contracts.
/// //TODO documentation
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
