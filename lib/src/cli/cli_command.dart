import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

abstract class CliCommand extends Command<void> {
  CliCommand() {
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Verbose mode.',
      defaultsTo: false,
    );
  }

  bool get verbose => argResults!['verbose'];

  @override
  FutureOr<void> run() async {
    try {
      await runCommand();
    } catch (e, stack) {
      stdout.write('\n\u001b[31m$e\u001b[0m\n');
      if (argResults?['verbose'] ?? false) {
        stdout.write('\u001b[31m$stack\u001b[0m\n');
      }
    }

    stdout.writeln();
  }

  Future<T> step<T>(String stepName, FutureOr<T> Function() delegate) async {
    stdout.write('  \u23F3   $stepName');
    try {
      final result = await delegate();
      stdout.write('\u001b[1000D  \u2713   $stepName\n');
      return result;
    } catch (e) {
      stdout.write('\u001b[1000D  \u{1F4A5}  $stepName\n');
      rethrow;
    }
  }

  Future<void> runCommand();
}
