part of 'service_host.dart';


abstract interface class Service implements Component {
  ServiceInstance createInstance();
}

abstract class ServiceInstance<TService extends Service> {
  late final TService service;
  late final ServiceRegistry registry;
  late final Object _scopeKey;

  FutureOr<void> initialize() async {}

  FutureOr<void> dispose() async {}

  T find<T>(Find<T> finder) => registry.find<T>(finder, _scopeKey);
}
