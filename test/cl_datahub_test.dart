import 'dart:io';

import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:test/test.dart';

import 'endpoints/article_endpoint.dart';

class Api extends ApiBase {
  Api(List<ApiEndpoint> resources) : super(resources);
}

void main() {
  group('ApiBase', () {
    late final ApiBase api;

    setUp(() {
      api = Api([
        ArticleEndpoint()
      ]);
    });

    test('serve and cancel', () async {
      final token = CancellationToken();
      final task = api.serve(InternetAddress.loopbackIPv4.address, 8083,
          cancellationToken: token);
      await Future.delayed(Duration(seconds: 3));
      token.cancel();
      await task;
    }, timeout: Timeout(Duration(minutes: 5)));
  });
}
