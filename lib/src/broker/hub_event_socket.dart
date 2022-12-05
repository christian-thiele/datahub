import 'package:datahub/broker.dart';
import 'package:datahub/src/broker/hub_event.dart';
import 'package:datahub/transfer_object.dart';

import 'event_hub_service.dart';

//TODO docs
class HubEventSocket<T> {
  final EventHubService _hub;
  final String topic;
  final TransferBean<T>? bean;

  HubEventSocket(this._hub, this.topic, {this.bean});

  Future<void> publish(T event) => _hub.publish(topic, event);

  /// Returns a stream of events delivered by this socket.
  ///
  /// Consider using [HubConsumerService.listen] instead.
  ///
  /// HubEvents are expected to be acknowledged or rejected by the consumer.
  ///
  /// Subscribing twice inside of the same service (even across instances)
  /// will result in competing consumers. The service is identified via
  /// the config value `datahub.serviceName`.
  Stream<HubEvent<T>> get stream => _hub.subscribe<T>(topic, bean: bean);
}
