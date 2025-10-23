import 'package:datahub/datahub.dart';

import 'docker_config_reference.dart';
import 'docker_ipam.dart';

part 'docker_network_create_request.g.dart';

@Data()
class DockerNetworkCreateRequest extends $DockerNetworkCreateRequest {
  @JsonKey('Name')
  final String name;
  @JsonKey('Driver')
  final String? driver;
  @JsonKey('Scope')
  final String? scope;
  @JsonKey('Internal')
  final bool? internal;
  @JsonKey('Attachable')
  final bool? attachable;
  @JsonKey('Ingress')
  final bool? ingress;
  @JsonKey('ConfigOnly')
  final bool configOnly;
  @JsonKey('ConfigFrom')
  final DockerConfigReference? configFrom;
  @JsonKey('IPAM')
  final DockerIPAM? ipam;
  @JsonKey('EnableIPv4')
  final bool? enableIPv4;
  @JsonKey('EnableIPv6')
  final bool? enableIPv6;
  @JsonKey('Options')
  final Map<String, String> options;
  @JsonKey('Labels')
  final Map<String, String> labels;

  const DockerNetworkCreateRequest({
    required this.name,
    this.driver,
    this.scope,
    this.internal,
    this.attachable,
    this.ingress,
    this.configOnly = false,
    this.configFrom,
    this.ipam,
    this.enableIPv4,
    this.enableIPv6,
    this.options = const {},
    this.labels = const {},
  });
}
