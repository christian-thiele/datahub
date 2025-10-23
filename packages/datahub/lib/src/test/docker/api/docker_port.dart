import 'package:datahub/datahub.dart';

part 'docker_port.g.dart';

@Data()
class DockerPort extends $DockerPort {
  @JsonKey('IP')
  final String ip;
  @JsonKey('PrivatePort')
  final int privatePort;
  @JsonKey('PublicPort')
  final int publicPort;
  @JsonKey('Type')
  final String type;

  const DockerPort({
    required this.ip,
    required this.privatePort,
    required this.publicPort,
    required this.type,
  });
}

