import 'package:datahub/src/broker/broker_message.dart';

abstract class BrokerQueue {
  final String name;

  BrokerQueue(this.name);

  Stream<BrokerMessage> getConsumer({bool noAck = true});

  Future<void> delete({bool ifEmpty = false, bool ifUnused = false});
}
