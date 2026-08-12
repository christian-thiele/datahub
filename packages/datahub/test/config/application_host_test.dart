import 'dart:io';

import 'package:datahub/config.dart';
import 'package:datahub/scaffold.dart';
import 'package:test/test.dart';

/// Initializes an [ApplicationHost] with [arguments] and returns its resolved
/// configuration.
Future<Configuration> resolve(
  List<String> arguments, {
  Map<String, dynamic> initialConfig = const {},
}) async {
  final host = ApplicationHost(
    components: const [],
    arguments: arguments,
    initialConfig: initialConfig,
  );
  await host.initialize();
  addTearDown(host.shutdown);
  return host.configuration;
}

void main() {
  late Directory tempDir;
  late File fileA;
  late File fileB;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('datahub_config_test');
    fileA = File('${tempDir.path}/a.yaml')..writeAsStringSync('key: fromFileA');
    fileB = File('${tempDir.path}/b.yaml')..writeAsStringSync('key: fromFileB');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('ApplicationHost - argument ordering', () {
    // Regression: ArgParser invokes option callbacks grouped by option rather
    // than in the order the arguments were given, which made config files
    // always win over -c directives no matter how they were ordered.
    test('a directive after a file overrides the file', () async {
      final config = await resolve(['-f', fileA.path, '-c', 'key=fromArg']);
      expect(config.read<String>(ConfigPath('key')), 'fromArg');
    });

    test('a file after a directive overrides the directive', () async {
      final config = await resolve(['-c', 'key=fromArg', '-f', fileA.path]);
      expect(config.read<String>(ConfigPath('key')), 'fromFileA');
    });

    test('files are applied in the order they are given', () async {
      final config = await resolve(['-f', fileB.path, '-f', fileA.path]);
      expect(config.read<String>(ConfigPath('key')), 'fromFileA');
    });

    test('directives are applied in the order they are given', () async {
      final config = await resolve(['-c', 'key=first', '-c', 'key=second']);
      expect(config.read<String>(ConfigPath('key')), 'second');
    });

    test('interleaved directives and files respect their order', () async {
      final config = await resolve([
        '-c',
        'key=first',
        '-f',
        fileA.path,
        '-c',
        'key=second',
        '-f',
        fileB.path,
      ]);
      expect(config.read<String>(ConfigPath('key')), 'fromFileB');
    });

    test('command line overrides initialConfig', () async {
      final config = await resolve(
        ['-c', 'key=fromArg'],
        initialConfig: {'key': 'fromInitial'},
      );
      expect(config.read<String>(ConfigPath('key')), 'fromArg');
    });
  });

  group('ApplicationHost - argument syntax', () {
    test('long form with a separate value', () async {
      final config = await resolve([
        '--file',
        fileA.path,
        '--config',
        'key=fromArg',
      ]);
      expect(config.read<String>(ConfigPath('key')), 'fromArg');
    });

    test('long form with an attached value', () async {
      final config = await resolve([
        '--file=${fileA.path}',
        '--config=key=fromArg',
      ]);
      expect(config.read<String>(ConfigPath('key')), 'fromArg');
    });

    test('abbreviation with an attached value', () async {
      final config = await resolve(['-f${fileA.path}', '-ckey=fromArg']);
      expect(config.read<String>(ConfigPath('key')), 'fromArg');
    });

    test('values are not consumed as options after --', () async {
      final config = await resolve(['-c', 'key=fromArg', '--', '-c', 'x=y']);
      expect(config.read<String>(ConfigPath('key')), 'fromArg');
      expect(config.read<String?>(ConfigPath('x')), isNull);
    });

    test('a directive value that looks like an option is kept', () async {
      final config = await resolve(['-c', 'key=-f']);
      expect(config.read<String>(ConfigPath('key')), '-f');
    });
  });
}
