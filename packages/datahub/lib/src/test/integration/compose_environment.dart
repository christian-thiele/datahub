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

  static Future<void>? _reapFuture;

  static io.Directory get _stateDirectory => io.Directory(
    '${io.Directory.systemTemp.path}${io.Platform.pathSeparator}datahub_test_environments',
  );

  Future<ComposeEnvironmentInstance> up() async {
    await reapStaleEnvironments();

    final projectId = 'datahub_test_${uuid()}';
    final parsedCompose = loadYaml(compose) as Map;
    final services = parsedCompose['services'] as Map;
    final servicePorts = <(String, int)>[];

    for (final (serviceName, service) in services.tuples) {
      final ports = service['ports'] as List?;
      for (final port in ports ?? const []) {
        final parts = port.toString().split(':');
        final containerPort = switch (parts.length) {
          1 => int.parse(parts[0]),
          _ => int.parse(parts[1]),
        };

        servicePorts.add((serviceName, containerPort));
      }
    }

    await _writeStateFile(projectId);

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
      final error = await utf8.decodeStream(process.stderr);
      // containers may exist even though up failed (e.g. failed health check)
      await _composeDown(projectId);
      await _deleteStateFile(projectId);
      throw StateError('docker compose up failed:\n$error');
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

  /// Removes environments whose owning test process no longer exists.
  ///
  /// Every [up] call registers its compose project in a state directory.
  /// A test process that is killed before `docker compose down` runs
  /// (debugger stop, SIGKILL, crash) leaves its containers behind; the next
  /// test run detects the dead owner process and removes the leftovers.
  ///
  /// Runs once per isolate; subsequent calls await the first invocation.
  static Future<void> reapStaleEnvironments() =>
      _reapFuture ??= _reapStaleEnvironments();

  static Future<void> _reapStaleEnvironments() async {
    final directory = _stateDirectory;
    if (!await directory.exists()) {
      return;
    }

    await for (final entry in directory.list()) {
      if (entry is! io.File || !entry.path.endsWith('.json')) {
        continue;
      }

      try {
        final state =
            jsonDecode(await entry.readAsString()) as Map<String, dynamic>;
        final pid = state['pid'] as int;
        final projectId = state['projectId'] as String;
        if (pid == io.pid ||
            !projectId.startsWith('datahub_test_') ||
            await _isProcessAlive(pid)) {
          continue;
        }

        await _composeDown(projectId);
        await entry.delete();
      } on Exception {
        // unreadable or concurrently removed state file, skip
      }
    }
  }

  static Future<bool> _isProcessAlive(int pid) async {
    if (io.Platform.isWindows) {
      final result = await io.Process.run('tasklist', [
        '/FI',
        'PID eq $pid',
        '/NH',
      ]);
      return result.stdout.toString().contains('$pid');
    } else {
      final result = await io.Process.run('kill', ['-0', '$pid']);
      // "operation not permitted" means the process exists
      return result.exitCode == 0 ||
          result.stderr.toString().toLowerCase().contains('not permitted');
    }
  }

  /// Removes all resources of a compose project by project name.
  ///
  /// Works without a compose file since docker compose finds resources
  /// via the `com.docker.compose.project` label.
  static Future<void> _composeDown(String projectId) async {
    final process = await io.Process.start('docker', [
      'compose',
      '-p',
      projectId,
      'down',
      '-v',
      '--remove-orphans',
    ]);
    await process.exitCode;
  }

  static Future<void> _writeStateFile(String projectId) async {
    final directory = _stateDirectory;
    await directory.create(recursive: true);
    final file = io.File(
      '${directory.path}${io.Platform.pathSeparator}$projectId.json',
    );
    await file.writeAsString(
      jsonEncode({
        'projectId': projectId,
        'pid': io.pid,
        'created': DateTime.now().toIso8601String(),
      }),
    );
  }

  static Future<void> _deleteStateFile(String projectId) async {
    try {
      await io.File(
        '${_stateDirectory.path}${io.Platform.pathSeparator}$projectId.json',
      ).delete();
    } on io.FileSystemException {
      // already removed
    }
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

  Map<String, dynamic> buildConfiguration({List<(String, String)>? remap}) {
    final servicesConfig = <String, Map<String, dynamic>>{};

    for (final service in servicePorts) {
      final serviceConfig = servicesConfig[service.name] ??=
          <String, dynamic>{};
      serviceConfig['host'] ??= '127.0.0.1';
      serviceConfig['port'] ??= service.hostPort;
      serviceConfig[service.containerPort.toString()] ??= service.hostPort;
    }

    return {'services': servicesConfig, 'composeProject': projectId};
  }

  Future<void> down() async {
    await ComposeEnvironment._composeDown(projectId);
    await ComposeEnvironment._deleteStateFile(projectId);
  }
}
