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

  const BrokerApi({
    this.brokerInterface,
    this.concurrent = false,
  });
}
