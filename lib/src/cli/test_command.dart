import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:datahub/src/cli/steps.dart';

import 'cli_command.dart';
import 'cli_exception.dart';
import 'utils.dart';

class TestCommand extends CliCommand {
  TestCommand();

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

    await codegenStep();

    await buildDebugStep([], 'test');

    final composeProcess =
        await step('Creating docker-compose environment.', () async {
      final result = await Process.start(
        'docker-compose',
        ['-f', 'test/docker-compose.yml', 'up'],
      );

      // TODO find out when containers are up
      await Future.delayed(Duration(seconds: 3));

      return result;
    });

    final process = await step('Starting test container.', () async {
      final executable = 'docker';
      final args = [
        'run',
        '--network=test_default',
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

    composeProcess.kill();
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
