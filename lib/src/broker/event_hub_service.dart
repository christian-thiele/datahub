import 'dart:async';
import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:datahub/src/broker/broker_channel.dart';
import 'package:datahub/src/broker/broker_exchange.dart';
import 'package:datahub/transfer_object.dart';
import 'package:datahub/utils.dart';

import 'broker_service.dart';
import 'hub_event.dart';
import 'hub_event_socket.dart';

abstract class EventHubService extends BaseService {
  final _log = resolve<LogService>();
  late final BrokerService _brokerService;
  final _channels = <BrokerChannel>[];
  late final Lazy<BrokerChannel> _publishChannel;

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
    _publishChannel = Lazy(() async => await _brokerService.openChannel()
      ..apply(_channels.add));
  }

  /// TODO DOCS
  HubEventSocket<T> event<T>(String topic, {TransferBean<T>? bean}) =>
      HubEventSocket<T>(this, topic, bean: bean);

  /// TODO DOCS
  EphemeralHubEventSocket<T> ephemeral<T>(String topic,
          {TransferBean<T>? bean}) =>
      EphemeralHubEventSocket<T>(this, topic, bean: bean);

  Future<void> publish<T>(String topic, T event) async {
    final encoded =
        (event is TransferObjectBase) ? event.toJson() : encodeTyped<T>(event);

    try {
      await _publishChannel
          .get()
          .then((c) => c.declareExchange(exchange, BrokerExchangeType.topic))
          .then((ex) => ex.publish(
              utf8.encode(jsonEncode(encoded)).asUint8List(), topic));
    } catch (e, stack) {
      _publishChannel.invalidate();
      _log.warn('Amqp channel error, reconnecting.', error: e, trace: stack);
      await _publishChannel
          .get()
          .then((c) => c.declareExchange(exchange, BrokerExchangeType.topic))
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
        final channel = await _brokerService.openChannel(prefetch: prefetch);
        _channels.add(channel);

        final queueName =
            '$exchange.${resolve<ConfigService>().serviceName}.$topic';
        final ex =
            await channel.declareExchange(exchange, BrokerExchangeType.topic);
        final q = await ex.declareAndBindQueue(queueName, [topic]);

        await controller.addStream(q.getConsumer(noAck: false).map((message) {
          return HubEvent(
            bean?.toObject(jsonDecode(utf8.decode(message.payload))) ??
                decodeTyped<T>(jsonDecode(utf8.decode(message.payload))),
            message.ack,
            message.reject,
          );
        }));
      } catch (e, stack) {
        controller.addError(e, stack);
      }
    };
    return controller.stream;
  }

  /// Subscribes to a topic of an EventHub.
  ///
  /// Consider using [HubConsumerService.listen] or [HubEventSocket.stream]
  /// instead.
  ///
  /// Subscribing twice inside of the same service and across instances
  /// will result in both consumers receiving all events emitted during
  /// their lifetime.
  Stream<HubEvent<T>> subscribePrivate<T>(String topic,
      {TransferBean<T>? bean, int? prefetch}) {
    //TODO reduce duplicate code with subscribe
    final controller = StreamController<HubEvent<T>>();
    controller.onListen = () async {
      try {
        final channel = await _brokerService.openChannel(prefetch: prefetch);
        _channels.add(channel);

        final ex =
            await channel.declareExchange(exchange, BrokerExchangeType.topic);
        final q = await ex.declareAndBindPrivateQueue([topic]);

        await controller.addStream(q.getConsumer(noAck: false).map((message) {
          return HubEvent(
            bean?.toObject(jsonDecode(utf8.decode(message.payload))) ??
                decodeTyped<T>(jsonDecode(utf8.decode(message.payload))),
            message.ack,
            message.reject,
          );
        }));
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
