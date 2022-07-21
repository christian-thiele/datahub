import 'package:args/command_runner.dart';
import 'package:datahub/src/cli/build_command.dart';
import 'package:datahub/src/cli/create_command.dart';

/// DataHub CLI Tool
void main(List<String> args) {
  final commandRunner = CommandRunner('datahub', 'DataHub CLI Tool');
  commandRunner.addCommand(CreateCommand());
  commandRunner.addCommand(BuildCommand());
  commandRunner.run(args);
}
