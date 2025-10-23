import 'package:datahub/datahub.dart';

part 'docker_network_settings.g.dart';

@Data()
class DockerNetworkSettings extends $DockerNetworkSettings {
  @JsonKey('Networks')
  final Map<String, dynamic> networks;

  const DockerNetworkSettings({required this.networks});
}

