import 'dart:async';
import 'dart:io';

import 'cli_command.dart';
import 'utils.dart';

class BuildCommand extends CliCommand {
  BuildCommand() {
    argParser.addFlag('debug', abbr: 'd', help: 'Build a debug image.');
    argParser.addOption('version', help: 'Override package version.');
  }

  @override
  String get description => 'Builds a Docker Image.\n'
      'The image will be tagged with the current version and the "latest" tag.';

  @override
  String get name => 'build';

  @override
  String get invocation => '${super.invocation} [docker build-args]';

  @override
  Future<void> runCommand() async {
    final projectName = await readName();
    final projectVersion = argResults!['version'] ?? await readVersion();

    stdout.write('Building $projectName ($projectVersion)...\n\n');

    if (argResults!['debug'] as bool) {
      await step('Run code generator.', () async {
        await dart(
          'run build_runner build --delete-conflicting-outputs',
          verbose: verbose,
        );
      });

      await step(
        'Building debug docker image.',
        () async {
          await requireFile('Dockerfile.debug');
          final dockerArgs = buildDockerArgs(argResults!.rest);
          await docker(
            'build -t $projectName:debug -f Dockerfile.debug$dockerArgs .',
            verbose: verbose,
          );
        },
      );

      stdout.writeln('\nBuilt debug image: $projectName:debug');
    } else {
      await step(
        'Building release docker image.',
        () async {
          await requireFile('Dockerfile');
          final dockerArgs = buildDockerArgs(argResults!.rest);
          await docker(
            'build -t $projectName:latest$dockerArgs .',
            verbose: verbose,
          );
        },
      );
      await step(
        'Adding version tag.',
        () async {
          await docker(
            'tag $projectName:latest $projectName:$projectVersion',
            verbose: verbose,
          );
        },
      );

      stdout.writeln('\nBuilt release image: $projectName:$projectVersion');
    }
  }
}
