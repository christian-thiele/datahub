import 'dart:io';

import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:test/test.dart';

import 'endpoints/article_endpoint.dart';
import 'endpoints/article_resource.dart';

class Api extends ApiBase {
  Api(List<ApiEndpoint> resources) : super(resources);
}

void main() {
  group('ApiBase', ()
  {
    test('serve and cancel', () async {
      final api = Api([
        ArticleEndpoint()
      ]);

      final token = CancellationToken();
      final task = api.serve(InternetAddress.loopbackIPv4.address, 8083,
          cancellationToken: token);
      await Future.delayed(Duration(seconds: 3));
      token.cancel();
      await task;
    }, timeout: Timeout(Duration(minutes: 5)));

    test('serve and cancel 2', () async {
      final api = Api([
        ArticleResource()
      ]);

      final token = CancellationToken();
      final task = api.serve(InternetAddress.loopbackIPv4.address, 8083,
          cancellationToken: token);
      await Future.delayed(Duration(seconds: 3));
      //token.cancel();
      await task;
    }, timeout: Timeout(Duration(minutes: 5)));
  });
}
