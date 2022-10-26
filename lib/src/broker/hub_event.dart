import 'package:datahub/transfer_object.dart';

import 'event_hub_service.dart';

//TODO docs
class HubEvent<T> {
  final EventHubService _hub;
  final String topic;
  final TransferBean<T>? bean;

  HubEvent(this._hub, this.topic, {this.bean});

  Future<void> publish(T event) => _hub.publish(topic, event);

  Stream<T> get stream => _hub.subscribe<T>(topic, bean: bean);
}
