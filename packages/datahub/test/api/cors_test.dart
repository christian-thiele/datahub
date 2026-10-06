import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/expect.dart';

const _allowedOrigin = 'https://allowed.example';
const _otherOrigin = 'https://other.example';

final _api = [
  ApiService(
    port: Config.value(0),
    routes: [
      CorsMiddleware(
        routes: [
          ResourceEndpoint(
            matcher: RoutePattern('/cors/test'),
            get: (request) => {'result': 'ok'},
          ),
          ApiMiddlewareDelegate(
            routes: [
              ResourceEndpoint(
                matcher: RoutePattern('/cors/protected'),
                get: (request) => {'result': 'ok'},
              ),
            ],
            delegate: (request, next) =>
                throw ApiRequestException.unauthorized(),
          ),
        ],
      ),
      ResourceEndpoint(
        matcher: RoutePattern('/test'),
        get: (request) => {'result': 'ok'},
      ),
    ],
  ),
];

void main() {
  declareTest('CORS: any origin', _api, () async {
    final client = Find<Api>().find().connectHttp11();

    final response = await client.get(
      '/cors/test',
      headers: {
        HttpHeaders.origin: [_otherOrigin],
      },
    );
    expect(response.statusCode, equals(200));
    expect(response.headers[HttpHeaders.accessControlAllowOrigin], ['*']);
    expect(response.headers[HttpHeaders.accessControlAllowCredentials], isNull);
    expect(response.headers[HttpHeaders.vary], isNull);
    expect(await response.getJsonBody(), equals({'result': 'ok'}));

    final noOrigin = await client.get('/cors/test');
    expect(noOrigin.headers[HttpHeaders.accessControlAllowOrigin], isNull);

    final outside = await client.get(
      '/test',
      headers: {
        HttpHeaders.origin: [_otherOrigin],
      },
    );
    expect(outside.headers[HttpHeaders.accessControlAllowOrigin], isNull);

    final preflight = await _preflight(client, '/cors/test', _otherOrigin);
    expect(preflight.statusCode, equals(204));
    expect(preflight.headers[HttpHeaders.accessControlAllowOrigin], ['*']);
    expect(
      preflight.headers[HttpHeaders.accessControlAllowMethods],
      equals(['GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE']),
    );
    expect(
      preflight.headers[HttpHeaders.accessControlAllows],
      equals(['authorization', 'x-api-key']),
    );
    expect(preflight.headers[HttpHeaders.accessControlMaxAge], isNull);

    // a plain OPTIONS request is not a preflight and reaches the endpoint
    final options = await client.request(
      HttpRequestMethod.options,
      RoutePattern('/cors/test'),
      {},
      headers: {
        HttpHeaders.origin: [_otherOrigin],
      },
      throwOnError: false,
    );
    expect(options.statusCode, equals(405));
    expect(options.headers[HttpHeaders.accessControlAllowOrigin], ['*']);
  });

  declareTest(
    'CORS: configured origins',
    _api,
    config: {
      'cors': {
        'allowedOrigins': [_allowedOrigin],
        'allowedHeaders': ['x-api-key'],
        'exposedHeaders': ['x-total-count'],
        'allowCredentials': true,
        'maxAge': 600000,
      },
    },
    () async {
      final client = Find<Api>().find().connectHttp11();

      final allowed = await client.get(
        '/cors/test',
        headers: {
          HttpHeaders.origin: [_allowedOrigin],
        },
      );
      expect(allowed.statusCode, equals(200));
      expect(
        allowed.headers[HttpHeaders.accessControlAllowOrigin],
        equals([_allowedOrigin]),
      );
      expect(
        allowed.headers[HttpHeaders.accessControlAllowCredentials],
        equals(['true']),
      );
      expect(
        allowed.headers[HttpHeaders.accessControlExposes],
        equals(['x-total-count']),
      );
      expect(allowed.headers[HttpHeaders.vary], equals(['Origin']));

      final denied = await client.get(
        '/cors/test',
        headers: {
          HttpHeaders.origin: [_otherOrigin],
        },
      );
      expect(denied.statusCode, equals(200));
      expect(denied.headers[HttpHeaders.accessControlAllowOrigin], isNull);
      expect(denied.headers[HttpHeaders.vary], equals(['Origin']));

      final preflight = await _preflight(client, '/cors/test', _allowedOrigin);
      expect(preflight.statusCode, equals(204));
      expect(
        preflight.headers[HttpHeaders.accessControlAllowOrigin],
        equals([_allowedOrigin]),
      );
      expect(
        preflight.headers[HttpHeaders.accessControlAllows],
        equals(['x-api-key']),
      );
      expect(
        preflight.headers[HttpHeaders.accessControlMaxAge],
        equals(['600']),
      );

      final deniedPreflight = await _preflight(
        client,
        '/cors/test',
        _otherOrigin,
      );
      expect(deniedPreflight.statusCode, equals(403));
      expect(
        deniedPreflight.headers[HttpHeaders.accessControlAllowOrigin],
        isNull,
      );

      // error responses carry CORS headers, so browsers expose them
      final unauthorized = await client.get(
        '/cors/protected',
        headers: {
          HttpHeaders.origin: [_allowedOrigin],
        },
        throwOnError: false,
      );
      expect(unauthorized.statusCode, equals(401));
      expect(
        unauthorized.headers[HttpHeaders.accessControlAllowOrigin],
        equals([_allowedOrigin]),
      );
    },
  );
}

Future<RestResponse> _preflight(
  RestClient client,
  String path,
  String origin,
) => client.request(
  HttpRequestMethod.options,
  RoutePattern(path),
  {},
  headers: {
    HttpHeaders.origin: [origin],
    HttpHeaders.accessControlRequestMethod: ['PUT'],
    HttpHeaders.accessControlRequests: ['authorization, x-api-key'],
  },
  throwOnError: false,
);
