/// Annotation for generated config classes.
///
/// [ConfigGenerator] generates code that uses boosts ConfigParser to
/// load configuration values from command line arguments and
/// environment variables.
///
/// ## Usage:
/// Create a class with final fields and an unnamed constructor (PODO).
/// This class can implement config interfaces like [ApiConfig] to provide
/// configuration values to built-in services when used with [ConfigService].
///
/// Example:
/// ```
/// import 'package:boost/boost.dart';
/// import 'package:cl_datahub/config.dart';
///
/// part 'my_config.g.dart';
///
/// @GenerateConfig()
/// class MyConfig implements ApiConfig {
///   // implements ApiConfig
///   @override
///   String get address => InternetAddress.anyIPv4;
///
///   // implements ApiConfig
///   @ConfigOption(defaultValue: 80)
///   final int port;
///
///   @ConfigOption(defaultValue: 'dev')
///   final String environment;
///
///   final int? someValue;
///
///   @ConfigOption(env: 'JAVA_HOME')
///   final String javaHome;
///
///   FileHubConfig(
///     this.address,
///     this.port,
///     this.environment,
///     this.javaHome, {
///     this.someValue,
///   });
/// }
/// ```
///
/// To make values optional, make their field nullable and
/// the constructor parameter optional (like `someValue`).
class GenerateConfig {
  final String? envPrefix;

  const GenerateConfig({this.envPrefix});
}
