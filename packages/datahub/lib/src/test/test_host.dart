import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:datahub/scaffold.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';

import 'package:test/test.dart' as dart_test;
import 'package:yaml_edit/yaml_edit.dart';

part 'test_runner_service.dart';

class TestHost extends ServiceHost {
  final List<Component> components;
  final Map<String, dynamic> initialConfig;
  final FutureOr<void> Function() testBody;

  TestHost({
    required this.components,
    required this.initialConfig,
    required this.testBody,
  });

  @override
  Component buildRoot() {
    return Scope(
      name: 'root',
      components: [
        Scope(name: 'internal', components: [TelemetryService()]),
        Scope(name: 'application', components: components),
        Scope(name: 'test', components: [TestRunnerService()]),
      ],
    );
  }

  @override
  Future<void> initialize() async {
    configuration.addConfigMap(initialConfig);
    return await super.initialize();
  }
}

void declareTest(
  String name,
  List<Component> components,
  FutureOr<void> Function() body, {
  dart_test.Timeout? timeout,
  Object? skip,
  Map<String, dynamic> config = const {},
  String? compose,
}) {
  if (compose != null) {
    if (!bool.hasEnvironment('DATAHUB_DOCKER_TEST')) {
      // The test is supposed to run in a docker-compose environment but
      // is currently running on the host.
      dart_test.group(name, () {
        dart_test.test(name, () async {
          print('setting up docker environment');
          final yaml = YamlEditor(File(compose).readAsStringSync());
          final services = yaml.parseAt(['services']);
          final composeProject = uuid();
          yaml.update(
            ['services', 'runner'],
            {
              'image': 'dart:3.9',
              'working_dir': '/app',
              'command': 'dart test .',
              'volumes': './:/app:ro',
              'depends_on': {
                for (final service
                    in (services as Map).keys.whereType<String>())
                  service: {'condition': 'service_healthy'},
              },
            },
          );

          print(yaml.toString());

          final composeProcess = await Process.start('docker', [
            'compose',
            'up',
            '-p',
            composeProject,
            '-f',
            '-',
            '-d',
          ]);

          composeProcess.stdout.listen(stdout.add);
          composeProcess.stderr.listen(stderr.add);
          composeProcess.stdin.add(utf8.encode(yaml.toString()));
          composeProcess.stdin.close();
          await composeProcess.exitCode;
        });
      });

      return;
    }
  }

  dart_test.group(name, () {
    TestHost? host;
    dart_test.setUp(() async {
      host = TestHost(
        components: components,
        initialConfig: config,
        testBody: body,
      );
      await host?.initialize();
    });

    dart_test.test(
      name,
      () async => await host!
          .findComponent(Find<_TestRunnerServiceInstance>(), null)
          .runTest(body),
      timeout: timeout,
      skip: skip,
    );

    dart_test.tearDown(() async {
      if (host?.state == ServiceHostState.initialized) {
        await host?.shutdown();
      }
    });
  });
}
