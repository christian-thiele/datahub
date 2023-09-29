import 'dart:async';

import 'package:dart_amqp/dart_amqp.dart' as amqp;
import 'package:datahub/src/broker/amqp/amqp_broker_exchange.dart';
import 'package:datahub/src/broker/amqp/amqp_broker_message.dart';
import 'package:datahub/src/broker/broker_message.dart';
import 'package:datahub/src/broker/broker_queue.dart';

class AmqpBrokerQueue extends BrokerQueue {
  final amqp.Queue amqpQueue;

  AmqpBrokerQueue(this.amqpQueue, super.name);

  @override
  Stream<BrokerMessage> getConsumer({bool noAck = true}) {
    final controller = StreamController<BrokerMessage>();
    try {
      amqpQueue.consume(noAck: noAck).then((value) {
        value.listen(
          (event) => controller.add(AmqpBrokerMessage(event)),
          onError: controller.addError,
          onDone: controller.close,
        );
        controller.onCancel = value.cancel;
      }).catchError((e, stack) async {
        controller.addError(e, stack);
        await controller.close();
      });
    } catch (e, stack) {
      controller.addError(e, stack);
      controller.close();
    }

    return controller.stream;
  }

  Future<void> bind(
      AmqpBrokerExchange amqpBrokerExchange, List<String> topics) async {
    for (final topic in topics) {
      await amqpQueue.bind(amqpBrokerExchange.amqpExchange, topic);
    }
  }

  Future<void> unbind(
      AmqpBrokerExchange amqpBrokerExchange, List<String> topics) async {
    for (final topic in topics) {
      await amqpQueue.unbind(amqpBrokerExchange.amqpExchange, topic);
    }
  }

  @override
  Future<void> delete({bool ifEmpty = false, bool ifUnused = false}) async {
    await amqpQueue.delete(ifEmpty: ifEmpty, ifUnused: ifUnused);
  }
}
