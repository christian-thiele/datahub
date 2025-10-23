import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/docker/api/docker_create_container_request.dart';
import 'package:datahub/src/test/docker/api/docker_network_create_request.dart';
import 'package:datahub/src/test/docker/docker_client.dart';

class DockerTestService {
  final String name;
  final String image;
  final Map<String, String> env;

  DockerTestService(this.name, this.image, {this.env = const {}});
}

class DockerTestEnvironment {
  final String envId = uuid();
  final DockerClient client;
  final List<DockerTestService> services;
  String? _networkId;
  final _containerIds = <String>[];

  DockerTestEnvironment({required this.client, required this.services});

  Future<void> up() async {
    await down();

    _networkId = await client.createNetwork(
      DockerNetworkCreateRequest(name: 'datahub-test-$envId'),
    );

    for (final service in services) {
      _containerIds.add(
        await client.createContainer(
          'test-$envId-${service.name}',
          DockerCreateContainerRequest(
            image: service.image,
            hostname: service.name,
            labels: {'datahub-test-env': envId},
          ),
        ),
      );
    }
  }

  Future<void> down() async {
    while (_containerIds.isNotEmpty) {
      final id = _containerIds.removeLast();
      await client.removeContainer(id, force: true, volumes: true);
    }

    if (_networkId case final networkId?) {
      await client.removeNetwork(networkId);
      _networkId = null;
    }
  }
}
