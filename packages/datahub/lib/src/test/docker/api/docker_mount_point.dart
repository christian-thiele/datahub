import 'package:datahub/datahub.dart';

import 'docker_mount_point_type.dart';

part 'docker_mount_point.g.dart';

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
