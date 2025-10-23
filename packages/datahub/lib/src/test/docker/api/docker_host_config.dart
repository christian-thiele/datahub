import 'package:datahub/datahub.dart';

part 'docker_host_config.g.dart';

@Data()
class DockerHostConfig extends $DockerHostConfig {
  @JsonKey('NetworkMode')
  final String networkMode;

  @JsonKey('Annotations')
  final Map<String, String> annotations;

  const DockerHostConfig({
    required this.networkMode,
    required this.annotations,
  });
}