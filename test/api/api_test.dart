import 'dart:io';

import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/config.dart';
import 'package:cl_datahub/src/api/middleware/log_middleware.dart';
import 'package:test/test.dart';

import 'endpoints/article_endpoint.dart';
import 'endpoints/article_resource.dart';

class Api extends ApiBase {
  Api(List<ApiEndpoint> resources)
      : super(resources, middleware: (internal) => LogMiddleware(internal));
}

class _TestConfig extends ApiConfig {
  @override
  final address = InternetAddress.loopbackIPv4;

  @override
  final port = 8083;
}

class TestConfigService extends ConfigService<_TestConfig> {
  @override
  final config = _TestConfig();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> shutdown() async {}
}

void main() {
  group('ApiBase', () {
    test('Serve and Cancel', () async {
      final token = CancellationToken();
      final serviceHost = ServiceHost([
        () => TestConfigService(),
        () => ApiService(Api([ArticleEndpoint()]))
      ], catchSignal: false);
      final task = serviceHost.run(token);
      await Future.delayed(Duration(seconds: 3));
      token.cancel();
      await task;
    }, timeout: Timeout(Duration(minutes: 5)));

    test('Hub Resource', () async {
      final api = Api([ArticleResource()]);

      final token = CancellationToken();
      final task = api.serve(InternetAddress.loopbackIPv4.address, 8083,
          cancellationToken: token);
      await Future.delayed(Duration(seconds: 3));

      ///TODO test requests

      token.cancel();
      await task;
    }, timeout: Timeout(Duration(minutes: 5)));
  });
}
