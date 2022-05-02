part of 'service_host.dart';

abstract class BaseService {
  final String configPath;

  BaseService(this.configPath);

  T config<T>([String? path]) {

  }

  Future<void> initialize();
  Future<void> shutdown();
}
