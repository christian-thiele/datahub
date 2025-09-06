part of 'service_host.dart';

class Scope implements Component {
  final String? name;
  final List<Component> components;

  Scope({this.name, required this.components});
}
