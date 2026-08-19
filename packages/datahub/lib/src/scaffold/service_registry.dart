import 'package:datahub/config.dart';
import 'package:datahub/src/scaffold/tree_node.dart';
import 'service_host.dart';

abstract interface class ServiceRegistry {
  /// Why the host running these services was started.
  HostPurpose get purpose;

  T findComponent<T>(Find<T> finder, TreeNode scope);

  T readConfig<T>(Config<T> config, TreeNode scope);

  void register<T extends Service>(T service);

  void registerPostInitializationCallback(void Function() callback);
}
