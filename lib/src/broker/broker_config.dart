/// Interface for config models that implement Message Broker
/// connection configuration.
///
/// Usually consumed by [BrokerService].
abstract class BrokerConfig {
  String get brokerHost;
  int get brokerPort;

  String get brokerUser;
  String get brokerPassword;
}
