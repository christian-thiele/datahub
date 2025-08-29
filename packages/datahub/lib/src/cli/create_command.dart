import 'dart:async';
import 'dart:io';

import 'package:boost/boost.dart';
import 'package:path/path.dart';

import 'cli_command.dart';
import 'cli_exception.dart';
import 'resources/debug_config.dart';
import 'resources/dockerfile.dart';
import 'resources/hello_world/hello_world_main.dart';
import 'resources/hello_world/hello_world_service.dart';
import 'resources/readme.dart';
import 'utils.dart';

class CreateCommand extends CliCommand {
  CreateCommand() {
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Force create project.\n'
          'Does not cancel if the directory already exists.',
    );
  }

  @override
  String get description => 'Creates a new DataHub Project.';

  @override
  String get name => 'create';

  @override
  Future<void> runCommand() async {
    final projectName = argResults!.rest.firstOrNull ??
        (throw CliException('Missing project name.'));

    assertValidPackageName(projectName);
    stdout.write('Creating project "$projectName"...\n\n');
    final baseDir = Directory(projectName);

    await step(
      'Creating dart package.',
      () async {
        final force = argResults?['force'] ?? false;
        if (!force && await baseDir.exists()) {
          throw CliException(
              'Directory "$projectName" already exists in working dir.');
        }

        await dart(
          'create $projectName -t console --no-pub' + (force ? ' --force' : ''),
          verbose: verbose,
        );
      },
    );

    await step('Creating DataHub project structure.', () async {
      await createOrReplace(
        File(join(baseDir.path, 'README.md')),
        createReadme(projectName),
      );

      await createOrReplace(
        File(join(baseDir.path, 'Dockerfile')),
        createDockerfile(projectName),
      );

      await createOrReplace(
        File(join(baseDir.path, 'Dockerfile.debug')),
        createDebugDockerfile(projectName),
      );

      final resources = Directory(join(baseDir.path, 'resources'));
      await resources.create();

      await createOrReplace(
        File(join(resources.path, 'debug.yaml')),
        createDebugConfig(projectName),
      );

      final services = Directory(join(baseDir.path, 'lib', 'src', 'services'));
      await services.create(recursive: true);

      await createOrReplace(
        File(join(services.path, 'hello_world_service.dart')),
        helloWorldServiceFile,
      );

      await createOrReplace(
        File(join(baseDir.path, 'lib', '$projectName.dart')),
        "export 'src/services/hello_world_service.dart';",
      );

      await createOrReplace(
        File(join(baseDir.path, 'bin', '$projectName.dart')),
        createHelloWorldMain(projectName),
      );

      await createOrReplace(
        File(join(baseDir.path, 'test', '${projectName}_test.dart')),
        'void main() {\n// TODO Add tests\n}\n',
      );

      await dart(
        'format .',
        baseDir: baseDir,
        verbose: verbose,
      );
    });

    await step('Adding dependencies.', () async {
      await dart(
        'pub add boost datahub',
        baseDir: baseDir,
        verbose: verbose,
      );
      await dart(
        'pub add --dev datahub_codegen build_runner',
        baseDir: baseDir,
        verbose: verbose,
      );
    });

    await step('Running pub get.', () async {
      await dart(
        'pub get',
        baseDir: baseDir,
        verbose: verbose,
      );
    });
  }
}
