import 'package:datahub/datahub.dart';

part 'docker_ipamconfig.g.dart';

@Data()
class DockerIPAMConfig extends $DockerIPAMConfig {
  @JsonKey('Subnet')
  final String? subnet;
  @JsonKey('IPRange')
  final String? ipRange;
  @JsonKey('Gateway')
  final String? gateway;
  @JsonKey('AuxiliaryAddresses')
  final Map<String, String> auxiliaryAddresses;

  const DockerIPAMConfig({
    this.subnet,
    this.ipRange,
    this.gateway,
    this.auxiliaryAddresses = const {},
  });
}
