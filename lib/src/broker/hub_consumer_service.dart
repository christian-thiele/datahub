import 'dart:async';

import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';

import 'event_hub_service.dart';
import 'hub_event.dart';

//TODO docs
abstract class HubConsumerService<THub extends EventHubService>
    extends BaseService {
  final _log = resolve<LogService>();
  final _subscriptions = <StreamSubscription>[];
  late final hub = resolve<THub>();

  HubConsumerService([super.path]);

  void listen<TEvent>(
    HubEvent<TEvent> hubEvent,
    FutureOr<void> Function(TEvent event) listener,
  ) {
    _subscriptions.add(hubEvent.stream.listen((event) async {
      try {
        await listener(event);
      } catch (e, stack) {
        _log.e(
          'Could not process event.',
          error: e,
          trace: stack,
        );
      }
    }));
  }

  @override
  Future<void> shutdown() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
  }
}
