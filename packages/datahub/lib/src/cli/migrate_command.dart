import 'dart:io';

import 'package:datahub/scaffold.dart';

import 'cli_command.dart';
import 'cli_exception.dart';
import 'utils.dart';

/// Runs a migration command against the project in the working directory.
///
/// The CLI cannot see the project's data model - dart has no reflection and
/// the project is not linked into this executable - so the work happens in the
/// project's own process. This command is the shortcut for
/// `dart run bin/<project>.dart migrate ...`, which [runApp] picks up.
class MigrateCommand extends CliCommand {
  MigrateCommand() {
    argParser
      ..addFlag(
        'empty',
        help: 'Create an empty migration to write by hand ("new" only).',
        negatable: false,
      )
      ..addFlag(
        'dry-run',
        help: 'Print the statements without running them ("apply" only).',
        negatable: false,
      )
      ..addFlag(
        'allow-destructive',
        help: 'Allow migrations that can lose data ("apply" only).',
        negatable: false,
      )
      ..addMultiOption(
        'config',
        abbr: 'c',
        help: 'Set a configuration value, as in -c postgres.host=localhost.',
      )
      ..addMultiOption(
        'file',
        abbr: 'f',
        help: 'Read configuration from a file.',
      );
  }

  @override
  String get name => 'migrate';

  @override
  String get description =>
      'Manages the database schema of this project.\n'
      '\n'
      '  new <name>   Generate a migration for the changes to the data model.\n'
      '  plan         Show what a new migration would contain.\n'
      '  status       Show which migrations are applied and which are not.\n'
      '  apply        Apply the pending migrations.\n'
      '  verify       Report how the database differs from the history.\n'
      '  baseline     Adopt a database that already has the schema.';

  @override
  String get invocation => '${super.invocation} <command> [<name>]';

  @override
  Future<void> runCommand() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      throw CliException(
        'Missing migration command. '
        'Expected one of: ${MigrationCommand.names.join(', ')}.',
      );
    }

    final command = rest.first;
    if (!MigrationCommand.names.contains(command)) {
      throw CliException(
        'Unknown migration command "$command". '
        'Expected one of: ${MigrationCommand.names.join(', ')}.',
      );
    }

    final projectName = await readName();
    final entryPoint = 'bin/$projectName.dart';
    await requireFile(entryPoint);

    final arguments = [
      'run',
      entryPoint,
      MigrationCommand.keyword,
      ...rest,
      for (final flag in const ['empty', 'dry-run', 'allow-destructive'])
        if (argResults!.flag(flag)) '--$flag',
      for (final value in argResults!.multiOption('config')) ...['-c', value],
      for (final value in argResults!.multiOption('file')) ...['-f', value],
    ];

    final process = await Process.start(
      'dart',
      arguments,
      mode: ProcessStartMode.inheritStdio,
    );

    exitCode = await process.exitCode;
  }
}
