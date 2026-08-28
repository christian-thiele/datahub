import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'cli_command.dart';
import 'cli_exception.dart';
import 'utils.dart';

class OpenApiCommand extends CliCommand {
  OpenApiCommand() {
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output file for the OpenAPI document.',
      defaultsTo: 'openapi.json',
    );
    argParser.addOption(
      'entrypoint',
      abbr: 'e',
      help:
          'Path to the application entrypoint. Defaults to '
          'bin/<package name>.dart, bin/main.dart or the single dart file '
          'in bin/.',
    );
    argParser.addMultiOption(
      'config',
      abbr: 'c',
      help: 'Config values passed to the application.',
    );
    argParser.addMultiOption(
      'file',
      abbr: 'f',
      help: 'Config files passed to the application.',
    );
    argParser.addOption(
      'title',
      help: 'API title. Defaults to the package name.',
    );
    argParser.addOption(
      'api-version',
      help: 'API version. Defaults to the package version.',
    );
    argParser.addOption(
      'timeout',
      help: 'Timeout in seconds for the application to produce the document.',
      defaultsTo: '120',
    );
  }

  @override
  String get description =>
      'Generates an OpenAPI 3.0.3 document from the ApiServices of this '
      'project.\n'
      'The application entrypoint is run in describe mode, which builds the '
      'API structure without starting servers or connecting to databases.';

  @override
  String get name => 'openapi';

  @override
  Future<void> runCommand() async {
    final title = argResults!['title'] ?? await readName();
    final version = argResults!['api-version'] ?? await readVersion();
    final output = argResults!['output'] as String;
    final entrypoint = await _resolveEntrypoint(argResults!['entrypoint']);

    stdout.write('Generating OpenAPI document for $title ($version)...\n\n');

    final tmpDir = await Directory.systemTemp.createTemp('datahub_openapi');
    try {
      final tmpFile = File('${tmpDir.path}/openapi.json');

      await step('Running $entrypoint in describe mode.', () async {
        await _runDescribe(entrypoint, tmpFile, title, version);
      });

      await step('Writing $output.', () async {
        await createOrReplace(File(output), await tmpFile.readAsString());
      });

      stdout.writeln('\nOpenAPI document written to $output');
    } finally {
      await tmpDir.delete(recursive: true);
    }
  }

  Future<String> _resolveEntrypoint(String? provided) async {
    if (provided != null) {
      await requireFile(provided);
      return provided;
    }

    final candidates = [
      'bin${Platform.pathSeparator}${await readName()}.dart',
      'bin${Platform.pathSeparator}main.dart',
    ];
    for (final candidate in candidates) {
      if (await File(candidate).exists()) {
        return candidate;
      }
    }

    final binDir = Directory('bin');
    if (await binDir.exists()) {
      final dartFiles = await binDir
          .list()
          .where((e) => e is File && e.path.endsWith('.dart'))
          .map((e) => e.path)
          .toList();
      if (dartFiles.length == 1) {
        return dartFiles.single;
      }
    }

    throw CliException(
      'Could not determine the application entrypoint. '
      'Specify it with -e <path>.',
    );
  }

  Future<void> _runDescribe(
    String entrypoint,
    File outFile,
    String title,
    String version,
  ) async {
    final timeout = Duration(
      seconds:
          int.tryParse(argResults!['timeout']) ??
          (throw CliException('Invalid timeout value.')),
    );

    final process = await Process.start(
      'dart',
      [
        'run',
        entrypoint,
        for (final value in argResults!['config'] as List<String>) ...[
          '-c',
          value,
        ],
        for (final file in argResults!['file'] as List<String>) ...['-f', file],
      ],
      environment: {
        'DATAHUB_DESCRIBE': 'openapi',
        'DATAHUB_DESCRIBE_OUT': outFile.path,
        'DATAHUB_DESCRIBE_TITLE': title,
        'DATAHUB_DESCRIBE_VERSION': version,
      },
    );

    final stderrBuffer = StringBuffer();
    final outputDone = Future.wait([
      process.stdout.transform(utf8.decoder).forEach((chunk) {
        if (verbose) {
          stdout.write(chunk);
        }
      }),
      process.stderr.transform(utf8.decoder).forEach((chunk) {
        stderrBuffer.write(chunk);
        if (verbose) {
          stderr.write(chunk);
        }
      }),
    ]);

    var timedOut = false;
    final exitCode = await process.exitCode.timeout(
      timeout,
      onTimeout: () {
        timedOut = true;
        process.kill();
        return -1;
      },
    );
    await outputDone;

    final warnings = stderrBuffer
        .toString()
        .split('\n')
        .where((line) => line.startsWith('Warning: '));
    for (final warning in warnings) {
      stdout.writeln('  ⚠️   $warning');
    }

    if (!await outFile.exists()) {
      if (timedOut) {
        throw CliException(
          'The application did not produce an OpenAPI document within '
          '${timeout.inSeconds}s. Ensure it depends on a datahub version '
          'that supports describe mode and awaits ApplicationHost.run().',
        );
      }
      final error = stderrBuffer.toString().trim();
      throw CliException(
        'The application exited with code $exitCode without producing an '
        'OpenAPI document.\n'
        '${error.isNotEmpty ? '$error\n' : ''}'
        'Hint: missing config values can be passed with -c key=value or '
        '-f config.yaml.',
      );
    }
  }
}
