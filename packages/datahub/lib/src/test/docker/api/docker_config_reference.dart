import 'package:datahub/datahub.dart';

part 'docker_config_reference.g.dart';

@Data()
class DockerConfigReference extends $DockerConfigReference {
  @JsonKey('Network')
  final String? network;
  const DockerConfigReference({this.network});
}
