import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:test/test.dart';

import 'endpoints/article_endpoint.dart';
import 'endpoints/article_resource.dart';

class Api extends ApiService {
  Api(List<ApiEndpoint> resources)
      : super(null, resources,
            middleware: (internal) => LogMiddleware(internal));
}

void main() {
  group('ApiBase', () {
    test('Serve and Cancel', () async {
      final token = CancellationToken();
      final serviceHost = ServiceHost(
        [
          () => Api([ArticleEndpoint()]),
        ],
        catchSignal: false,
      );
      final task = serviceHost.run(token);
      await Future.delayed(Duration(seconds: 3));
      token.cancel();
      await task;
    }, timeout: Timeout(Duration(minutes: 5)));

    test('Hub Resource', () async {
      final token = CancellationToken();
      final serviceHost = ServiceHost(
        [
          () => Api([ArticleResource()]),
        ],
        catchSignal: false,
      );
      final task = serviceHost.run(token);
      await Future.delayed(Duration(seconds: 3));
      token.cancel();
      await task;
    }, timeout: Timeout(Duration(minutes: 5)));
  });
}
