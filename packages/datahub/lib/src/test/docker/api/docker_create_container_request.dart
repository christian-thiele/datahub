import 'package:datahub/datahub.dart';

import 'docker_host_config.dart';

part 'docker_create_container_request.g.dart';

@Data()
class DockerCreateContainerRequest extends $DockerCreateContainerRequest {
  @JsonKey('Hostname')
  final String? hostname;
  @JsonKey('Domainname')
  final String? domainName;
  @JsonKey('User')
  final String? user;
  @JsonKey('AttachStdin')
  final bool? attachStdin;
  @JsonKey('AttachStdout')
  final bool? attachStdout;
  @JsonKey('AttachStderr')
  final bool? attachStderr;
  @JsonKey('ExposedPorts')
  final Map<String, dynamic> exposedPorts;
  @JsonKey('Tty')
  final bool? tty;
  @JsonKey('OpenStdin')
  final bool? openStdin;
  @JsonKey('StdinOnce')
  final bool? stdinOnce;
  @JsonKey('Env')
  final List<String> env;
  @JsonKey('Cmd')
  final List<String> cmd;

  // TODO implement HealthCheck
  // @JsonKey('Healthcheck') final DockerHealthCheck? healthcheck;
  @JsonKey('ArgsEscaped')
  final bool? argsEscaped;
  @JsonKey('Image')
  final String? image;

  // TODO implement Volumes
  // @JsonKey('Volumes') final DockerVolumes? volumes;
  @JsonKey('WorkingDir')
  final String? workingDir;
  @JsonKey('Entrypoint')
  final List<String>? entryPoint;
  @JsonKey('NetworkDisabled')
  final bool? networkDisabled;
  @JsonKey('MacAddress')
  final String? macAddress;
  @JsonKey('OnBuild')
  final List<String>? onBuild;
  @JsonKey('Labels')
  final Map<String, String> labels;
  @JsonKey('StopSignal')
  final String? stopSignal;
  @JsonKey('StopTimeout')
  final int? stopTimeout;
  @JsonKey('Shell')
  final List<String>? shell;
  @JsonKey('HostConfig')
  final List<DockerHostConfig>? hostConfig;

  // TODO implement DockerNetworkingConfig
  // @JsonKey('NetworkingConfig') final List<DockerNetworkingConfig>? networkingConfig;

  const DockerCreateContainerRequest({
    this.hostname,
    this.domainName,
    this.user,
    this.attachStdin,
    this.attachStdout,
    this.attachStderr,
    this.exposedPorts = const {},
    this.tty,
    this.openStdin,
    this.stdinOnce,
    this.env = const [],
    this.cmd = const [],
    this.argsEscaped,
    this.image,
    this.workingDir,
    this.entryPoint,
    this.networkDisabled,
    this.macAddress,
    this.onBuild,
    this.labels = const {},
    this.stopSignal,
    this.stopTimeout,
    this.shell,
    this.hostConfig,
  });
}
