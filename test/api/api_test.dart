import 'dart:io';

import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/src/api/middleware/log_middleware.dart';
import 'package:test/test.dart';

import 'endpoints/article_endpoint.dart';
import 'endpoints/article_resource.dart';

class Api extends ApiBase {
  Api(List<ApiEndpoint> resources)
      : super(resources, middleware: (internal) => LogMiddleware(internal));
}

void main() {
  group('ApiBase', () {
    test('Serve and Cancel', () async {
      final token = CancellationToken();
      final serviceHost = ServiceHost([
        () => ApiService(Api([ArticleEndpoint()]), InternetAddress.loopbackIPv4.address, 8083)
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
