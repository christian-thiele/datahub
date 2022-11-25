// TODO put eventHubEndpoint as property of dto then publish with autodetected topic subscribe according to bean
// TODO docs
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

  HubEvent<T> event<T>(String topic, {TransferBean<T>? bean}) =>
      HubEvent<T>(this, topic, bean: bean);

  Future<void> publish<T>(String topic, T event) async {
    final channel = await _publishChannel.get();
    final ex = await channel.exchange(exchange, ExchangeType.TOPIC);
    final encoded =
        (event is TransferObjectBase) ? event.toJson() : encodeTyped<T>(event);

    ex.publish(encoded, topic);
  }

  Stream<T> subscribe<T>(String topic,
      {String? queue, TransferBean<T>? bean}) async* {
    final channel = await _brokerService.openChannel();
    _channels.add(channel);
    final ex = await channel.exchange(exchange, ExchangeType.TOPIC);
    final q = await ex.bindQueueConsumer(queue ?? '', [topic], noAck: false);
    final controller = StreamController<T>();
    q.listen(
      (message) {
        if (bean != null) {
          controller.add(bean.toObject(jsonDecode(message.payloadAsString)));
        } else {
          controller.add(decodeTyped<T>(message.payloadAsJson));
        }
      },
      onError: controller.addError,
      onDone: controller.close,
    );
    controller.onCancel = q.cancel;
    yield* controller.stream;
  }

  @override
  Future<void> shutdown() async {
    for (final channel in _channels) {
      await channel.close();
    }
  }
}
