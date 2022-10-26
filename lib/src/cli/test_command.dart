import 'dart:async';
import 'dart:io';

import 'package:datahub/src/cli/steps.dart';

import 'cli_command.dart';
import 'utils.dart';

class TestCommand extends CliCommand {
  TestCommand() {
    argParser.addFlag(
      'build',
      defaultsTo: false,
      help: 'Builds the debug image before running tests.',
    );
    argParser.addFlag(
      'codegen',
      defaultsTo: false,
      help: 'Runs code generator before building / running tests.',
    );
    argParser.addFlag(
      'compose',
      defaultsTo: true,
      help: 'Starts the docker-compose environment automatically.',
    );
    argParser.addFlag(
      'mount',
      defaultsTo: true,
      help: 'Mounts the code inside the debug container.',
    );
    argParser.addOption(
      'network',
      defaultsTo: 'test_default',
      help: 'Specifies the docker network the test container is attached to.',
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

    Process? composeProcess;
    if (argResults!['compose']) {
      composeProcess =
          await step('Creating docker-compose environment.', () async {
        final result = await Process.start(
          'docker-compose',
          ['-f', 'test/docker-compose.yml', 'up'],
        );

        // TODO find out when containers are up
        await Future.delayed(Duration(seconds: 3));

        return result;
      });
    }

    final process = await step('Starting test container.', () async {
      final executable = 'docker';
      final args = [
        'run',
        '--network=${argResults!['network']}',
        if (argResults!['mount']) '--mount',
        if (argResults!['mount'])
          'type=bind,source="${Directory.current.absolute.toString()}",target="/app",readonly',
        '$projectName:test',
        'dart',
        'test',
        ...argResults!.rest,
      ];

      return await Process.start(executable, args);
    });

    stdout.writeln('\n');
    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);
    final exitCode = await process.exitCode;

    composeProcess?.kill();
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
