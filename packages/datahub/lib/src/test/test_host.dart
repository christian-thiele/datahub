import 'dart:async';
import 'dart:io';
import 'package:datahub/scaffold.dart';
import 'package:datahub/telemetry.dart';

import 'package:test/test.dart' as dart_test;

import 'integration/compose_environment.dart';

part 'test_runner_service.dart';

class TestHost extends ServiceHost {
  final List<Component> components;
  final Map<String, dynamic> initialConfig;
  final List<File> initialConfigFiles;
  final FutureOr<void> Function() testBody;

  TestHost({
    required this.components,
    required this.initialConfig,
    required this.initialConfigFiles,
    required this.testBody,
  });

  @override
  Component buildRoot() {
    return Scope(
      name: 'root',
      components: [
        Scope(name: 'internal', components: [TelemetryService(), KeyService()]),
        Scope(name: 'application', components: components),
        Scope(name: 'test', components: [TestRunnerService()]),
      ],
    );
  }

  @override
  Future<void> initialize() async {
    configuration.addConfigMap({
      'telemetry': {'logStdoutFormat': 'message', 'logLevel': 'info'},
    });
    for (final file in initialConfigFiles) {
      configuration.addConfigFile(file);
    }
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
  List<File> configFiles = const [],
  ComposeEnvironment? environment,
}) {
  dart_test.group(name, () {
    TestHost? host;

    final environmentConfig = <String, dynamic>{};
    if (environment case final environment?) {
      late final ComposeEnvironmentInstance environmentInstance;
      dart_test.setUpAll(() async {
        environmentInstance = await environment.up();
        final servicesConfig = <String, Map<String, dynamic>>{};

        for (final service in environmentInstance.servicePorts) {
          final serviceConfig = servicesConfig[service.name] ??=
              <String, dynamic>{};
          serviceConfig['host'] ??= '127.0.0.1';
          serviceConfig['port'] ??= service.hostPort;
          serviceConfig[service.containerPort.toString()] ??= service.hostPort;
        }

        environmentConfig['test'] = {
          'services': servicesConfig,
          'composeProject': environmentInstance.projectId,
        };
      });

      dart_test.tearDownAll(() async {
        await environmentInstance.down();
      });
    }

    dart_test.setUp(() async {
      host = TestHost(
        components: components,
        initialConfig: {...environmentConfig, ...config},
        initialConfigFiles: configFiles,
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
