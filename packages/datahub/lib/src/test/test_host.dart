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
  final FutureOr<void> Function() testBody;

  TestHost({required this.components, required this.testBody});

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

    Map<String, dynamic>? environmentConfig;
    if (environment case final environment?) {
      ComposeEnvironmentInstance? environmentInstance;
      dart_test.setUpAll(() async {
        final instance = await environment.up();
        environmentInstance = instance;
        environmentConfig = {'test': instance.buildConfiguration()};
      });

      dart_test.tearDownAll(() async {
        await environmentInstance?.down();
        environmentInstance = null;
      });
    }

    dart_test.setUp(() async {
      final testHost = TestHost(components: components, testBody: body);
      if (environmentConfig case final config?) {
        testHost.configuration.addConfigMap(config);
      }
      for (final file in configFiles) {
        testHost.configuration.addConfigFile(file);
      }
      testHost.configuration.addConfigMap(config);
      await testHost.initialize();
      host = testHost;
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
      host = null;
    });
  }, location: testLocation);
}
