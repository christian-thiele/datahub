import 'cli_command.dart';
import 'utils.dart';

extension CommonSteps on CliCommand {
  Future<void> codegenStep() async {
    await step('Run code generator.', () async {
      await dart(
        'run build_runner build --delete-conflicting-outputs',
        verbose: verbose,
      );
    });
  }

  Future<void> buildDebugStep(List<String> dockerArguments, String tag) async {
    await step(
      'Building debug docker image.',
      () async {
        final projectName = await readName();
        await requireFile('Dockerfile.debug');
        final dockerArgs = buildDockerArgs(dockerArguments);
        await docker(
          'build -t $projectName:$tag -f Dockerfile.debug$dockerArgs .',
          verbose: verbose,
        );
      },
    );
  }

  Future<void> buildReleaseStep(
      List<String> dockerArguments, String tag) async {
    await step(
      'Building release docker image.',
      () async {
        final projectName = await readName();
        await requireFile('Dockerfile');
        final dockerArgs = buildDockerArgs(dockerArguments);
        await docker(
          'build -t $projectName:$tag$dockerArgs .',
          verbose: verbose,
        );
      },
    );
  }
}
