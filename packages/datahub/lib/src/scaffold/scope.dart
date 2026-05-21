part of 'service_host.dart';

class Scope implements Component {
  final String? name;
  final String? config;
  final List<Component> components;

  Scope({this.name, this.config, required this.components});
}
