import 'dart:async';

import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';

import 'event_hub_service.dart';
import 'hub_event_socket.dart';

/// A service consuming and processing EventHub events.
///
/// To listen to events of a specific socket override the
/// [initialize] method and call [listen] with the socket and a handler
/// as arguments. The member field [hub] provides the instance of the
/// specified hub type from the current service scope.
///
/// See:
///   [EventHubService]
abstract class HubConsumerService<THub extends EventHubService>
    extends BaseService {
  final _log = resolve<LogService>();
  final _subscriptions = <StreamSubscription>[];
  late final hub = resolve<THub>();

  HubConsumerService([super.path]);

  /// Subscribes to a HubEventSocket.
  ///
  /// TODO docs ephemeral
  /// Subscribing twice inside of the same service (even across instances)
  /// will result in competing consumers. The service is identified via
  /// the config value `datahub.serviceName`.

  void listen<TEvent>(
    HubEventSocket<TEvent> hubSocket,
    FutureOr<void> Function(TEvent event) listener, {
    int? prefetch,
  }) {
    late StreamSubscription sub;
    sub = hubSocket.getStream(prefetch: prefetch).listen(
          (event) async {
            try {
              await listener(event.data);
              event.ack();
            } on StateError catch (e, stack) {
              _log.error(
                'Could not sent ack.',
                error: e,
                trace: stack,
              );
            } catch (e, stack) {
              event.reject(true);
              _log.e(
                'Could not process event.',
                error: e,
                trace: stack,
              );
            }
          },
          cancelOnError: true,
          onDone: () {
            _log.warn('done?');
          },
          onError: (e, stack) async {
            _log.warn(
              'HubSocket subscription failed, restarting.',
              error: e,
              trace: stack,
            );
            try {
              await sub.cancel().timeout(Duration(seconds: 30));
            } catch (e, stack) {
              _log.error(
                'Could not cancel subscription.',
                error: e,
                trace: stack,
              );
            }
            _subscriptions.remove(sub);
            await Future.delayed(const Duration(seconds: 3));
            listen(hubSocket, listener, prefetch: prefetch);
          },
        );
    _subscriptions.add(sub);
  }

  @override
  Future<void> shutdown() async {
    for (final sub in _subscriptions) {
      try {
        await sub.cancel();
      } catch (e, stack) {
        _log.error(
          'Could not cancel subscription.',
          error: e,
          trace: stack,
        );
      }
    }
    _subscriptions.clear();
  }
}
