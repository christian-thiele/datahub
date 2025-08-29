import 'dart:async';
import 'dart:io';

import 'package:datahub/src/cli/steps.dart';

import 'cli_command.dart';
import 'utils.dart';

class TestCommand extends CliCommand {
  TestCommand() {
    argParser.addFlag(
      'build',
      defaultsTo: true,
      help: 'Builds the debug image before running tests.',
    );
    argParser.addOption(
      'vm_service_port',
      help: 'The port on which the dart vm service listens on.',
      defaultsTo: '8181',
    );
    argParser.addFlag(
      'enable_vm_service',
      defaultsTo: false,
      help: 'Enables the dart vm service.',
    );
    argParser.addFlag(
      'pause_isolates_on_start',
      defaultsTo: false,
      help: 'Pauses all dart isolates until a debugger attaches.',
    );
    argParser.addFlag(
      'codegen',
      defaultsTo: false,
      help: 'Runs code generator before building / running tests.',
    );
    argParser.addFlag(
      'compose',
      defaultsTo: true,
      help: 'Starts the docker compose environment automatically.',
    );
    argParser.addFlag(
      'mount',
      defaultsTo: false,
      help: 'Mounts the code inside the debug container.',
    );
    argParser.addOption(
      'network',
      defaultsTo: 'test_default',
      help: 'Specifies the docker network the test container is attached to.',
    );
    argParser.addOption(
      'warmup',
      defaultsTo: '5',
      help:
          'Amount of time (in seconds) to wait for compose environment to warm up before starting tests.',
    );
  }

  @override
  String get description =>
      'Runs integration tests inside the test environment.\n'
      'A debug docker image will be built with the "test" tag.';

  @override
  String get name => 'test';

  @override
  String get invocation => '${super.invocation} [dart test args]';

  @override
  Future<void> runCommand() async {
    final projectName = await readName();

    await requireFile('test/docker-compose.yml');

    stdout.write('Running tests for $projectName...\n\n');

    if (argResults!['codegen']) {
      await codegenStep();
    }

    if (argResults!['build']) {
      await buildDebugStep([], 'test');
    }

    if (argResults!['compose']) {
      await step('Creating docker compose environment.', () async {
        return await Process.run(
          'docker',
          ['compose', '-f', 'test/docker-compose.yml', 'up', '-d'],
        );
      });

      final warmup = int.tryParse(argResults!['warmup'].toString()) ?? 0;
      if (warmup > 0) {
        await step(
          'Waiting for environment to warm up.',
          () async {
            await Future.delayed(Duration(seconds: warmup));
          },
        );
      }
    }

    final useVmService = argResults!['enable_vm_service'];
    final vmServicePort = argResults!['vm_service_port'];

    final process = await step('Starting test container.', () async {
      final executable = 'docker';
      final args = [
        'run',
        '--rm',
        '--network=${argResults!['network']}',
        if (useVmService) '-p',
        if (useVmService) '$vmServicePort:$vmServicePort',
        if (argResults!['mount']) '--mount',
        if (argResults!['mount'])
          'type=bind,source=${Directory.current.absolute.path.replaceAll('\\', '/')},target=/app',
        '$projectName:test',
        'dart',
        if (useVmService) '--enable-vm-service=$vmServicePort/0.0.0.0',
        if (argResults!['pause_isolates_on_start']) '--pause_isolates_on_start',
        'run',
        'test',
        '-r',
        'expanded',
        ...argResults!.rest,
      ];

      return await Process.start(executable, args);
    });

    stdout.writeln('\n');
    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);
    final exitCode = await process.exitCode;
    stdout.writeln('\n');

    if (argResults!['compose']) {
      await step('Disposing docker compose environment.', () async {
        final result = await Process.start(
          'docker',
          ['compose', '-f', 'test/docker-compose.yml', 'down'],
        );
        if (await result.exitCode > 0) {
          throw Exception('Exit code ${await result.exitCode}.');
        }
      });
    }

    exit(exitCode);
  }
}

class Test {
  final int id;
  final String name;
  final bool? success;
  final StringBuffer log;

  Test(this.id, this.name, [this.success, StringBuffer? log])
      : log = log ?? StringBuffer();

  Test done(bool success) => Test(id, name, success, log);
}
