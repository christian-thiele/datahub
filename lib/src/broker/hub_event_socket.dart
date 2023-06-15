import 'package:boost/boost.dart';
import 'package:datahub/transfer_object.dart';

import 'event_hub_service.dart';
import 'hub_event.dart';

class HubSocket<T> {
  final EventHubService _hub;
  final String topic;
  final TransferBean<T>? bean;

  HubSocket(this._hub, this.topic, {this.bean});
}

/// [HubEventSocket] for eventual consistent messages.
class HubEventSocket<T> extends HubSocket<T> {
  HubEventSocket(super._hub, super.topic, {super.bean});

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
  ///
  /// Queues are configured with a service specific name and autoDelete = false.
  Stream<HubEvent<T>> getStream({int? prefetch}) =>
      _hub.subscribe<T>(topic, bean: bean, prefetch: prefetch);
}

/// [HubEventSocket] for ephemeral event messages.
class EphemeralHubEventSocket<T> extends HubSocket<T> {
  EphemeralHubEventSocket(super._hub, super.topic, {super.bean});

  Future<void> publish(String subTopic, T event) =>
      _hub.publish(_topic(subTopic), event);

  /// Returns a stream of events delivered by this socket.
  ///
  /// Consider using [HubConsumerService.listen] instead.
  ///
  /// HubEvents are expected to be acknowledged or rejected by the consumer.
  ///
  /// With ephemeral hub event sockets, events can be filtered by [subTopic].
  ///
  /// Every subscription receives every event that becomes available while
  /// listening. Events are not guaranteed to achieve eventual persistence
  /// between listeners. Messages will be dropped if no consumer is available
  /// and will never be recorded for services that are not currently listening.
  ///
  /// Queues are configured with an auto-assigned name and autoDelete = true.
  Stream<HubEvent<T>> getStream(String subTopic, {int? prefetch}) =>
      _hub.subscribe<T>(_topic(subTopic), bean: bean, prefetch: prefetch);

  String _topic(String subTopic) =>
      [topic, subTopic].where((e) => !nullOrEmpty(subTopic)).join('.');
}
