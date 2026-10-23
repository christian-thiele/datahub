part of 'service_host.dart';

abstract interface class Service() implements Component {
  ServiceInstance createInstance();
}

@optionalTypeArgs
abstract class ServiceInstance<TService extends Service>() {
  late final TService service;
  late final ServiceRegistry registry;

  /// The zone of the instance.
  ///
  /// It has the context of the instance, but no active span, so the span of
  /// initializing the instance (or of a request) is not attached to
  /// everything done there.
  @protected
  late final Zone instanceZone;

  /// The context of the instance.
  late final Context context;

  @mustCallSuper
  Future<void> initialize() async {
    instanceZone = Tracer.detachedZone(Zone.current);
    // ignore: datahub_lints/avoid_zone_context_in_service
    context = Context.ofZone(instanceZone);
  }

  @mustCallSuper
  Future<void> dispose() async {}

  T find<T>(Find<T> finder) => context.find<T>(finder);

  T read<T>(Config<T> config) => context.read<T>(config);

  /// Runs [action] in [instanceZone], e.g. to start timers, connections or
  /// listeners that keep running after the caller (like a request) is done.
  @protected
  R inInstanceZone<R>(R Function() action) => instanceZone.run(action);
}
