import 'dart:io';

import 'package:yaml/yaml.dart';

import 'cli_exception.dart';

bool isValidPackageName(String packageName) {
  return RegExp(r'^[a-z][0-9a-z_]*$').hasMatch(packageName);
}

void assertValidPackageName(String packageName) {
  if (!isValidPackageName(packageName)) {
    throw CliException('Invalid project name "$packageName".\n'
        'Valid project are lower snake case and must not start with a number.');
  }
}

Future<String> readName() async {
  final pubspec = await readPubspec();
  return pubspec['name'] ??
      (throw CliException('Missing property "name" in pubspec.yaml.'));
}

Future<String> readVersion() async {
  final pubspec = await readPubspec();
  return pubspec['version'] ??
      (throw CliException('Missing property "version" in pubspec.yaml.'));
}

Future<YamlMap> readPubspec() async {
  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    throw CliException('No pubspec.yaml found in working directory.');
  }
  final pubspecRaw = await pubspecFile.readAsString();
  return loadYaml(pubspecRaw);
}

Future<void> dart(String args,
    {Directory? baseDir, bool verbose = false}) async {
  await command('dart', args, baseDir: baseDir, verbose: verbose);
}

Future<void> docker(String args,
    {Directory? baseDir, bool verbose = false}) async {
  await command('docker', args, baseDir: baseDir, verbose: verbose);
}

Future<void> command(String program, String args,
    {Directory? baseDir, bool verbose = false}) async {
  final process = await Process.start(
    program,
    args.split(' '),
    workingDirectory: baseDir?.path,
  );

  if (verbose) {
    stdout.writeln();
    await Future.wait([
      stdout.addStream(process.stdout),
      stderr.addStream(process.stderr),
    ]);
    stdout.writeln();
  } else {
    await Future.wait([
      process.stdout.drain(),
      process.stderr.drain(),
    ]);
  }

  final exitCode = await process.exitCode;
  if (exitCode > 0) {
    throw CliException(
        'Call "$program $args" failed with exit code $exitCode.');
  }
}

Future<void> createOrReplace(File file, String content) async {
  if (!await file.exists()) {
    await file.create();
  }

  await file.writeAsString(content);
}

Future<void> requireFile(String file) async {
  if (!await File(file).exists()) {
    throw CliException('$file not found.');
  }
}

String buildDockerArgs(List<String> args) {
  final buffer = StringBuffer();
  final regex = RegExp(r'^([^=]+)=(.*)$');
  for (final arg in args) {
    if (!regex.hasMatch(arg)) {
      throw CliException('Invalid build-arg: "$arg".');
    }
    buffer.write(' --build-arg $arg');
  }
  return buffer.toString();
}
