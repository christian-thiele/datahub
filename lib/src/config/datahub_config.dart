import 'environment.dart';
import 'log_level.dart';

class DatahubConfig {
  final LogLevel logLevel;
  final Environment environment;

  DatahubConfig({
    required this.logLevel,
    required this.environment,
  });
}
