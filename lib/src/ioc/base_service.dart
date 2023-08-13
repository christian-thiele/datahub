import 'package:datahub/services.dart';
import 'package:datahub/transfer_object.dart';

import 'service_resolver.dart';

/// Base class for all services.
///
/// See [ServiceHost] for more information.
abstract class BaseService {
  final ConfigPath? configPath;
  final ServiceResolver _resolver;

  BaseService([String? path])
      : configPath = path == null ? null : ConfigPath(path),
        _resolver = ServiceResolver.current;

  /// Fetch the environment configuration from [ConfigService].
  Environment get environment =>
      _resolver.resolveService<ConfigService>().environment;

  /// Fetches a configuration value from [ConfigService].
  T config<T>(String path) {
    final relative = ConfigPath(path);
    final absolute = configPath?.join(relative) ?? relative;
    return _resolver.resolveService<ConfigService>().fetch<T>(absolute);
  }

  /// Fetches a configuration value from [ConfigService] and parse it into the
  /// TransferObject.
  T configObject<T extends TransferObjectBase>(
      String path, TransferBean<T> bean) {
    final relative = ConfigPath(path);
    final absolute = configPath?.join(relative) ?? relative;
    return _resolver
        .resolveService<ConfigService>()
        .fetchObject<T>(absolute, bean);
  }

  Future<void> initialize() async {}

  Future<void> shutdown() async {}
}
