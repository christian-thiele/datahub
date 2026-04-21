import 'dart:async';
import 'dart:io';
import 'package:datahub/config.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/telemetry.dart';
import 'package:meta/meta.dart';
import 'package:stack_trace/stack_trace.dart';

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
        Scope(
          name: 'internal',
          components: [
            TelemetryService(
              logStdoutFormat: Config(
                'telemetry.logStdoutFormat',
                defaultValue: LogBodyFormat.message,
                values: LogBodyFormat.values,
              ),
              logLevel: const Config<SeverityLevel>(
                'telemetry.logLevel',
                defaultValue: SeverityLevel.info,
                values: SeverityLevel.values,
              ),
            ),
            KeyService(),
          ],
        ),
        Scope(name: 'application', components: components),
        Scope(name: 'test', components: [TestRunnerService()]),
      ],
    );
  }

  @override
  Future<void> initialize() async {
    for (final file in initialConfigFiles) {
      configuration.addConfigFile(file);
    }
    configuration.addConfigMap(initialConfig);
    return await super.initialize();
  }
}

@isTest
void declareTest(
  String name,
  List<Component> components,
  FutureOr<void> Function() body, {
  dart_test.Timeout? timeout,
  Object? skip,
  Object? tags,
  Map<String, dynamic> config = const {},
  List<File> configFiles = const [],
  ComposeEnvironment? environment,
}) {
  final traceFrame = Trace.current(1).frames.first;
  final testLocation = dart_test.TestLocation(
    traceFrame.uri,
    traceFrame.line ?? 0,
    traceFrame.column ?? 0,
  );

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
      tags: tags,
      location: testLocation,
    );

    dart_test.tearDown(() async {
      if (host?.state == ServiceHostState.initialized) {
        await host?.shutdown();
      }
    });
  }, location: testLocation);
}
