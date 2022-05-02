import 'package:cl_datahub/config.dart';
import 'package:cl_datahub/ioc.dart';

abstract class BaseService {
  final ConfigPath? configPath;

  BaseService([String? path])
      : configPath = path == null ? null : ConfigPath(path);

  /// Fetches a configuration value from [ConfigService].
  T config<T>(String path, {T? defaultValue}) {
    final relative = ConfigPath(path);
    final absolute = configPath?.join(relative) ?? relative;
    return resolve<ConfigService>().fetchConfig<T>(absolute, defaultValue);
  }

  Future<void> initialize();

  Future<void> shutdown();
}
