import 'package:args/command_runner.dart';
import 'package:datahub/src/cli/build_command.dart';
import 'package:datahub/src/cli/create_command.dart';
import 'package:datahub/src/cli/test_command.dart';

/// DataHub CLI Tool
void main(List<String> args) async {
  final commandRunner = CommandRunner('datahub', 'DataHub CLI Tool');
  commandRunner.addCommand(CreateCommand());
  commandRunner.addCommand(BuildCommand());
  commandRunner.addCommand(TestCommand());
  try {
    await commandRunner.run(args);
  } on UsageException catch (e) {
    print(e);
  }
}
