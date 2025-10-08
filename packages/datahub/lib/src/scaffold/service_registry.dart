import 'package:datahub/config.dart';
import 'package:datahub/src/scaffold/tree_node.dart';
import 'package:datahub/utils.dart';
import 'service_host.dart';

abstract interface class ServiceRegistry {
  T findComponent<T>(Find<T> finder, TreeNode scope);

  T readConfig<T>(Config<T> config, TreeNode scope);

  void register<T extends Service>(T service);
}

class Find<T> {
  final Test<T> test;

  const Find([this.test = always]);

  bool isCandidate(ServiceInstance service) =>
      service is T && test(service as T);

  T find() => Context.ofZone().find(this);

  @override
  String toString() => 'Find<$T>';
}
