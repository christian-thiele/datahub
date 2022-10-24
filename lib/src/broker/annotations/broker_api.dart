/// Annotation for Broker APIs.
///
/// BrokerAPIs are server side implementations of [BrokerInterface]s.
///
/// When param [brokerInterface] is omitted, it is assumed that the annotated
/// class also serves as BrokerInterface.

@deprecated
class BrokerApi {
  final Type? brokerInterface;
  final bool concurrent;

  const BrokerApi({
    this.brokerInterface,
    this.concurrent = false,
  });
}
