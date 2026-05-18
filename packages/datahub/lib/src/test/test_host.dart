import 'dart:async';
import 'dart:io';
import 'package:datahub/scaffold.dart';
import 'package:datahub/telemetry.dart';

import 'package:test/test.dart' as dart_test;

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
}) {
  dart_test.group(name, () {
    TestHost? host;
    dart_test.setUp(() async {
      host = TestHost(
        components: components,
        initialConfig: config,
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
