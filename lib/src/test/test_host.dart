import 'dart:async';
import 'dart:io';

import 'package:datahub/api.dart';
import 'package:datahub/broker.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/rest_client.dart';
import 'package:test/expect.dart';

class TestHost extends ServiceHost {
  TestHost(
    super.factories, {
    super.config,
    super.args,
    super.failWithServices,
  });

  Future<void> Function() test<T extends ApiService>(
      [FutureOr<void> Function()? body]) {
    return () async {
      try {
        await initialize();
      } catch (_) {
        fail('TestHost does not initialize.');
      }

      try {
        if (body != null) {
          await runAsService(body);
        }
      } finally {
        try {
          await shutdown();
        } catch (_) {
          fail('TestHost does shutdown gracefully.');
        }
      }
    };
  }

  Future<void> Function() apiTest<T extends ApiService>(
      FutureOr<void> Function(RestClient client) body) {
    return test(() async {
      final api = resolve<T>();
      final client = await RestClient.connectHttp2(
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
    });
  }

  Future<void> Function() eventTest<T extends EventHubService>(
      FutureOr<void> Function(T hub) body) {
    return test(() async {
      final hub = resolve<T>();
      await body(hub);
    });
  }
}
