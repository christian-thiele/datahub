import 'dart:async';
import 'dart:io';

import 'package:datahub/api.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/rest_client.dart';
import 'package:test/test.dart' as dartTest;

class TestHost extends ServiceHost {
  TestHost(
    List<BaseService Function()> factories, {
    bool failWithServices = true,
    List<String> args = const <String>[],
    Map<String, dynamic> config = const <String, dynamic>{},
  }) : super(
          factories,
          failWithServices: failWithServices,
          args: args,
          config: {
            'datahub': {
              'log': 'debug',
              'environment': 'dev',
              'serviceName': 'unit-test',
            },
            ...config,
          },
        );

  void declare(void Function(TestHost host) scaffold,
      {bool useCommonHost = false}) {
    if (useCommonHost) {
      dartTest.setUpAll(setUp);
      dartTest.tearDownAll(tearDown);
    } else {
      dartTest.setUp(setUp);
      dartTest.tearDown(tearDown);
    }
    scaffold(this);
  }

  Future<void> setUp() async {
    try {
      await initialize();
    } catch (_) {
      dartTest.fail('TestHost does not initialize.');
    }
  }

  Future<void> tearDown() async {
    try {
      await shutdown();
    } catch (_) {
      dartTest.fail('TestHost does not shutdown gracefully.');
    }
  }

  /// Wrapper for defining test bodies.
  ///
  /// Wrapping the test body function with this method ensures that
  /// the test is run in a service zone which provides access to
  /// the [ServiceResolver] required by the [resolve] function.
  void test<T extends ApiService>(
    String name,
    FutureOr<void> Function() body, {
    dartTest.Timeout? timeout,
    Object? tags,
    Map<String, dynamic>? onPlatform,
    int? retry,
    Object? skip,
    String? testOn,
  }) {
    dartTest.test(
      name,
      () => runAsService(body),
      timeout: timeout,
      tags: tags,
      onPlatform: onPlatform,
      retry: retry,
      skip: skip,
      testOn: testOn,
    );
  }

  /// Wrapper for defining api test bodies.
  ///
  /// Wrapping the test body function with this method ensures that
  /// the test is run in a service zone which provides access to
  /// the [ServiceResolver] required by the [resolve] function.
  ///
  /// This method additionally provides access to a client connected to
  /// the selected [ApiService] of the host.
  void apiTest<T extends ApiService>(
    String name,
    FutureOr<void> Function(RestClient client) body, {
    dartTest.Timeout? timeout,
    Object? tags,
    Map<String, dynamic>? onPlatform,
    int? retry,
    Object? skip,
    String? testOn,
  }) {
    test(
      name,
      () async {
        final api = resolve<T>();
        final client = RestClient.connectHttp2(
          Uri(
            scheme: 'http',
            host: InternetAddress.loopbackIPv4.host,
            port: api.port,
            path: api.basePath,
          ),
        );
        try {
          await body(client);
        } finally {
          await client.close();
        }
      },
      timeout: timeout,
      tags: tags,
      onPlatform: onPlatform,
      retry: retry,
      skip: skip,
      testOn: testOn,
    );
  }
}
