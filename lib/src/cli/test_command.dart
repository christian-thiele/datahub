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
  String get invocation => '${super.invocation} [docker build-args]';

  @override
  Future<void> runCommand() async {
    final projectName = await readName();
    final projectVersion = argResults!['version'] ?? await readVersion();

    await requireFile('test/docker-compose.yml');

    stdout.write('Running tests for $projectName ($projectVersion)...\n\n');

    await codegenStep();

    await buildDebugStep(argResults!.rest, 'test');

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

    await step('Running tests.', () async {
      final executable = 'docker';
      final args = [
        'run',
        '--network=test_default',
        '$projectName:test',
        'dart',
        'test',
        '--reporter=json'
      ];

      final proc = await Process.start(executable, args);
      final lines = proc.stdout.transform(LineTransformer());
      final tests = <int, Test>{};
      await for (final line in lines) {
        try {
          final data = jsonDecode(line);
          switch (data['type']) {
            case 'testStart':
              tests[data['testID']] =
                  Test(data['testID'], data['name'], null, null);
              break;
            case 'testDone':
              tests[data['testID']] =
                  tests[data['testID']]!.done(data['result'] == 'success');
          }
        } catch (_) {
          //probably log
        }
      }

      final exitCode = await proc.exitCode;
      if (exitCode > 0) {
        throw CliException(
            'Call "$executable ${args.join(' ')}" failed with exit code $exitCode.');
      }
    });

    composeProcess.kill(ProcessSignal.sigint);

    stdout.writeln('\nTest run complete.');
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
