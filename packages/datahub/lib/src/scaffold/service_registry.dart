import 'package:datahub/utils.dart';
import 'service_host.dart';

abstract interface class ServiceRegistry {
  T find<T>(Find<T> finder, Object scopeKey);

  void register<T extends Service>(T service);

  void deRegister<T extends Service>(ServiceInstance<T> instance);
}

class Find<T> {
  final Test<T> test;

  const Find([this.test = always]);

  bool isCandidate(ServiceInstance service) =>
      service is T && test(service as T);

  @override
  String toString() => 'Find<$T>';
}
