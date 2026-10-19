part of 'service_host.dart';

class Scope({
  /// Config prefix for every [Config] path below this scope.
  final String? name,
  required final List<Component> components,
}) implements Component;
