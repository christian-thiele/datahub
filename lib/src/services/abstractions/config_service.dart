import 'package:cl_datahub/cl_datahub.dart';

/// Interface for modular configuration services.
///
/// Client code should provide an implementation of ConfigService<ConfigClass>
/// where `ConfigClass` is an immutable class also provided by client code
/// that holds the applications configuration values and implements config
/// interfaces like [ApiConfig] to provide config values to built-in services
/// as well as custom services.
///
/// This can be paired with ConfigParser from boost package to parse
/// configuration from command line args and environment variables.
abstract class ConfigService<Config> implements BaseService {
  Config get config;

  static Config resolve<Config>() =>
      ServiceHost
          .resolve<ConfigService<Config>>()
          .config;
}