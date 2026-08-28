part of 'service_host.dart';

abstract interface class Service implements Component {
  ServiceInstance createInstance();
}

@optionalTypeArgs
abstract class ServiceInstance<TService extends Service> {
  late final TService service;
  late final ServiceRegistry registry;
  late final Context context;

  @mustCallSuper
  Future<void> initialize() async {}

  @mustCallSuper
  Future<void> dispose() async {}

  T find<T>(Find<T> finder) => context.find<T>(finder);

  T read<T>(Config<T> config) => context.read<T>(config);
}
