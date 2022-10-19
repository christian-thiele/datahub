import 'dart:async';
import 'dart:io';

import 'package:datahub/api.dart';
import 'package:datahub/hub.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/rest_client.dart';

class TestHost extends ServiceHost {
  TestHost(
    super.factories, {
    super.config,
    super.args,
    super.failWithServices,
  });

  Future<void> Function() test<T extends ApiService>(
      FutureOr<void> Function() body) {
    return () async {
      await initialize();
      try {
        await body();
      } finally {
        await shutdown();
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
}
