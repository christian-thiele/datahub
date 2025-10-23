import 'package:datahub/datahub.dart';

import 'docker_ipamconfig.dart';

part 'docker_ipam.g.dart';

@Data()
class DockerIPAM extends $DockerIPAM {
  @JsonKey('Driver')
  final String? driver;
  @JsonKey('Config')
  final List<DockerIPAMConfig> config;
  @JsonKey('Options')
  final Map<String, String> options;

  const DockerIPAM({
    this.driver,
    this.config = const [],
    this.options = const {},
  });
}
