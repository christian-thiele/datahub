part of 'service_host.dart';

class Scope implements Component {
  /// Config prefix for every [Config] path below this scope.
  final String? name;
  final List<Component> components;

  Scope({this.name, required this.components});
}
