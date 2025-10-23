import 'package:datahub/datahub.dart';

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

enum DockerContainerState {
  created,
  running,
  paused,
  restarting,
  exited,
  removing,
  dead,
}

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

@Data()
class DockerNetworkSettings extends $DockerNetworkSettings {
  @JsonKey('Networks')
  final Map<String, dynamic> networks;

  const DockerNetworkSettings({required this.networks});
}

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

@Data()
class DockerMountPoint extends $DockerMountPoint {
  @JsonKey('Type')
  final DockerMountPointType type;

  @JsonKey('Name')
  final String name;

  @JsonKey('Source')
  final String source;

  @JsonKey('Destination')
  final String destination;

  @JsonKey('Driver')
  final String driver;

  @JsonKey('Mode')
  final String mode;

  @JsonKey('RW')
  final bool writable;

  @JsonKey('Propagation')
  final String propagation;

  const DockerMountPoint({
    required this.type,
    required this.name,
    required this.source,
    required this.destination,
    required this.driver,
    required this.mode,
    required this.writable,
    required this.propagation,
  });
}

enum DockerMountPointType { bind, volume, image, tmpfs, npipe, cluster }
