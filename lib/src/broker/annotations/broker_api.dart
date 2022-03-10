/// Annotation for Broker APIs.
///
/// BrokerAPIs are server side implementation of [BrokerInterface]
///
/// When param [brokerInterface] is omitted, it is assumed that the annotated
/// class also serves as BrokerInterface.
class BrokerApi {
  //TODO maybe we do not need this param and can detect from "extends ..."
  final Type? brokerInterface;
  final bool concurrent;

  //TODO those two should be inherited
  final bool durable;
  final String queueName;

  const BrokerApi({
    this.brokerInterface,
    this.concurrent = false,
    this.durable = true,
    required this.queueName,
  });
}
