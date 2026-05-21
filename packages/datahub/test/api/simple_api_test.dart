import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/expect.dart';

void main() {
  declareTest(
    'Simple REST Api',
    [
      ApiService(
        port: Config.value(0),
        routes: [
          ResourceEndpoint(
            matcher: RoutePattern('/test/special'),
            get: (request) =>
                ApiResponse.dynamic({'message': 'this is special'}),
            post: (request) => throw Exception('Something went wrong'),
          ),
          ApiEndpointDelegate(
            matcher: RoutePattern('/test/*'),
            delegate: (request) async => ApiResponse.dynamic({
              'uri': request.uri.toString(),
              'body': await request.getJsonBody(),
              'method': request.method.name,
            }),
          ),
        ],
      ),
    ],
    () async {
      final client = Find<Api>().find().connectHttp11();

      expect(
        await client.post('/test/something', {'hi': 123}).thenGetJsonBody(),
        equals({
          'uri': '/test/something',
          'body': {'hi': 123},
          'method': 'post',
        }),
      );

      expect(
        await client.get('/test/special').thenGetJsonBody(),
        equals({'message': 'this is special'}),
      );

      expect(
        () async => await client.post('/test/special', {}).thenGetJsonBody(),
        throwsA(
          isA<ApiRequestException>().having(
            (e) => e.statusCode,
            'statusCode',
            equals(500),
          ),
        ),
      );

      expect(
        () async => await client.patch('/test/special', {}).thenGetJsonBody(),
        throwsA(
          isA<ApiRequestException>().having(
            (e) => e.statusCode,
            'statusCode',
            equals(405),
          ),
        ),
      );

      expect(
        () async => await client.patch('/doesntexist', {}).thenGetJsonBody(),
        throwsA(
          isA<ApiRequestException>().having(
            (e) => e.statusCode,
            'statusCode',
            equals(404),
          ),
        ),
      );
    },
  );
}
