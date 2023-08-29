import 'package:datahub/ioc.dart';
import 'package:dart_amqp/dart_amqp.dart';

import 'broker_channel.dart';

/// Interface for message broker connections.
///
/// See [AmqpBrokerService]
abstract class BrokerService extends BaseService {
  BrokerService([String? path]) : super(path);
  Future<BrokerChannel> openChannel({int? prefetch});
}
