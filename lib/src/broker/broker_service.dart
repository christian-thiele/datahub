import 'package:cl_datahub/ioc.dart';
import 'package:dart_amqp/dart_amqp.dart';

/// Interface for message broker connections.
///
/// See [AmqpBrokerService]
abstract class BrokerService extends BaseService {
  Future<Channel> openChannel();
}
