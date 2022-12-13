import 'dart:async';
import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:dart_amqp/dart_amqp.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:datahub/transfer_object.dart';
import 'package:datahub/utils.dart';

import 'broker_service.dart';
import 'hub_event.dart';
import 'hub_event_socket.dart';

abstract class EventHubService extends BaseService {
  final _log = resolve<LogService>();
  late final BrokerService _brokerService;
  final _channels = <Channel>[];
  late final Lazy<Channel> _publishChannel;

  String get exchange;

  EventHubService([super.path]);

  @override
  Future<void> initialize() async {
    final service = resolve<BrokerService?>();
    if (service == null) {
      _log.e('A BrokerService is required to start the EventHubService. '
          'Try providing a BrokerService implementation before this '
          'service to your ServiceHost.');
      throw Exception('No BrokerService found in ServiceHost.');
    }
    _brokerService = service;
    //TODO reconnect on channel disconnect
    _publishChannel = Lazy(() async => await _brokerService.openChannel()
      ..apply(_channels.add));
  }

  HubEventSocket<T> event<T>(String topic, {TransferBean<T>? bean}) =>
      HubEventSocket<T>(this, topic, bean: bean);

  Future<void> publish<T>(String topic, T event) async {
    final encoded =
        (event is TransferObjectBase) ? event.toJson() : encodeTyped<T>(event);

    try {
      await _publishChannel
          .get()
          .then((c) => c.exchange(exchange, ExchangeType.TOPIC))
          .then((ex) => ex.publish(encoded, topic));
    } on StateError catch (e, stack) {
      _publishChannel.invalidate();
      _log.warn('Amqp channel state error, reconnecting.',
          error: e, trace: stack);
      await _publishChannel
          .get()
          .then((c) => c.exchange(exchange, ExchangeType.TOPIC))
          .then((ex) => ex.publish(encoded, topic));
    }
  }

  /// Subscribes to a topic of an EventHub.
  ///
  /// Consider using [HubConsumerService.listen] or [HubEventSocket.stream]
  /// instead.
  ///
  /// Subscribing twice inside of the same service (even across instances)
  /// will result in competing consumers. The service is identified via
  /// the config value `datahub.serviceName`.
  Stream<HubEvent<T>> subscribe<T>(String topic,
      {TransferBean<T>? bean, int? prefetch}) {
    final controller = StreamController<HubEvent<T>>();
    controller.onListen = () async {
      try {
        final channel = await _brokerService
            .openChannel()
            .then((c) => c.qos(prefetch, prefetch));
        _channels.add(channel);

        final queueName =
            '$exchange.${resolve<ConfigService>().serviceName}.$topic';
        final ex = await channel.exchange(exchange, ExchangeType.TOPIC);
        final q = await ex.bindQueueConsumer(queueName, [topic], noAck: false);
        q.listen(
          (message) {
            controller.add(HubEvent(
              bean?.toObject(jsonDecode(message.payloadAsString)) ??
                  decodeTyped<T>(message.payloadAsJson),
              message.ack,
              message.reject,
            ));
          },
          onError: controller.addError,
          onDone: controller.close,
        );
        controller.onCancel = q.cancel;
      } catch (e, stack) {
        controller.addError(e, stack);
      }
    };
    return controller.stream;
  }

  @override
  Future<void> shutdown() async {
    for (final channel in _channels) {
      await channel.close();
    }
  }
}
