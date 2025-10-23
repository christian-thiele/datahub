import 'package:datahub/datahub.dart';

import 'docker_container_state.dart';
import 'docker_host_config.dart';
import 'docker_mount_point.dart';
import 'docker_network_settings.dart';
import 'docker_port.dart';

part 'docker_container.g.dart';

@Data()
class DockerContainer extends $DockerContainer {
  @JsonKey('Id')
  final String id;

  @JsonKey('Names')
  final List<String> names;

  @JsonKey('Image')
  final String image;
  @JsonKey('ImageID')
  final String imageId;
  @JsonKey('Command')
  final String command;
  @JsonKey('Created')
  final int created;
  @JsonKey('Ports')
  final List<DockerPort> ports;
  @JsonKey('SizeRw')
  final int? sizeRw;
  @JsonKey('SizeRootFs')
  final int? sizeRootFs;
  @JsonKey('Labels')
  final Map<String, String> labels;
  @JsonKey('State')
  final DockerContainerState state;
  @JsonKey('Status')
  final String status;
  @JsonKey('HostConfig')
  final DockerHostConfig hostConfig;
  @JsonKey('NetworkSettings')
  final DockerNetworkSettings networkSettings;
  @JsonKey('Mounts')
  final List<DockerMountPoint> mounts;

  const DockerContainer({
    required this.id,
    required this.names,
    required this.image,
    required this.imageId,
    required this.command,
    required this.created,
    required this.ports,
    required this.sizeRw,
    required this.sizeRootFs,
    required this.labels,
    required this.state,
    required this.status,
    required this.hostConfig,
    required this.networkSettings,
    required this.mounts,
  });
}
