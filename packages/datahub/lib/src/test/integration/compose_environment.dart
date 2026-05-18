import 'dart:convert';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:datahub/utils.dart';
import 'package:yaml/yaml.dart';

class ServicePort {
  final String name;
  final int containerPort;
  final int hostPort;

  const ServicePort({
    required this.name,
    required this.containerPort,
    required this.hostPort,
  });
}

class ComposeEnvironment {
  final String compose;

  const ComposeEnvironment({required this.compose});

  ComposeEnvironment.fromFile(String path)
    : this(compose: io.File(path).readAsStringSync());

  Future<ComposeEnvironmentInstance> up() async {
    final projectId = 'datahub_test_${uuid()}';
    final parsedCompose = loadYaml(compose) as Map;
    final services = parsedCompose['services'] as Map;
    final servicePorts = <(String, int)>[];

    for (final (serviceName, service) in services.tuples) {
      final ports = service['ports'] as List?;
      if (ports != null) {
        for (final port in ports) {
          final parts = port.toString().split(':');
          final containerPort = switch (parts.length) {
            1 => int.parse(parts[0]),
            _ => int.parse(parts[1]),
          };

          servicePorts.add((serviceName, containerPort));
        }
      }
    }

    final process = await io.Process.start('docker', [
      'compose',
      '-p',
      projectId,
      '-f',
      '-',
      'up',
      '-d',
      if (servicePorts.isNotEmpty) '--wait',
      ...servicePorts.$1,
    ]);
    process.stdin.write(compose);
    await process.stdin.close();

    if (await process.exitCode != 0) {
      throw StateError(
        'docker compose up failed:\n${await utf8.decodeStream(process.stderr)}',
      );
    }

    return ComposeEnvironmentInstance(
      composeEnvironment: this,
      projectId: projectId,
      servicePorts: [
        for (final servicePort in servicePorts)
          ServicePort(
            name: servicePort.$1,
            containerPort: servicePort.$2,
            hostPort: await findPort(projectId, servicePort.$1, servicePort.$2),
          ),
      ],
    );
  }

  Future<int> findPort(
    String projectId,
    String service,
    int containerPort,
  ) async {
    final process = await io.Process.start('docker', [
      'compose',
      '-p',
      projectId,
      '-f',
      '-',
      'port',
      service,
      '$containerPort',
    ]);
    process.stdin.write(compose);
    await process.stdin.close();

    final output = await utf8.decodeStream(process.stdout);
    return int.parse(output.split(':').last);
  }
}

class ComposeEnvironmentInstance {
  final ComposeEnvironment composeEnvironment;
  final String projectId;
  final List<ServicePort> servicePorts;

  ComposeEnvironmentInstance({
    required this.composeEnvironment,
    required this.projectId,
    required this.servicePorts,
  });

  Future<void> down() async {
    final process = await io.Process.start('docker', [
      'compose',
      '-p',
      projectId,
      '-f',
      '-',
      'down',
      '-v',
      '--remove-orphans',
    ]);
    process.stdin.write(composeEnvironment.compose);
    await process.stdin.close();
    await process.exitCode;
  }
}
