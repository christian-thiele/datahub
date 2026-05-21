import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/expect.dart';

final middlewareImplicit = [
  ApiService(
    port: Config.value(0),
    routes: [
      ApiMiddlewareDelegate(
        routes: [
          ResourceEndpoint(
            matcher: RoutePattern('/middleware/test'),
            get: (request) => {'result': 'ok'},
          ),
          ResourceEndpoint(
            matcher: RoutePattern('/middleware/other'),
            get: (request) => {'result': 'ok'},
          ),
        ],
        delegate: (request, next) async {
          if (request.headers['x-api-key']?.firstOrNull == 'CORRECT-KEY') {
            return await next(request);
          } else {
            throw ApiRequestException.unauthorized();
          }
        },
      ),
      ResourceEndpoint(
        matcher: RoutePattern('/test'),
        get: (request) => {'result': 'ok'},
      ),
    ],
  ),
];

final middlewareExplicit = [
  ApiService(
    port: Config.value(0),
    routes: [
      ApiMiddlewareDelegate(
        matcher: RoutePattern('/middleware/*'),
        catchRequests: true,
        routes: [
          ResourceEndpoint(
            matcher: RoutePattern('/middleware/test'),
            get: (request) => {'result': 'ok'},
          ),
          ResourceEndpoint(
            matcher: RoutePattern('/middleware/other'),
            get: (request) => {'result': 'ok'},
          ),
        ],
        delegate: (request, next) {
          if (request.headers['x-api-key']?.firstOrNull == 'CORRECT-KEY') {
            return next(request);
          } else {
            throw ApiRequestException.unauthorized();
          }
        },
      ),
      ResourceEndpoint(
        matcher: RoutePattern('/test'),
        get: (request) => ApiResponse.dynamic({'result': 'ok'}),
      ),
    ],
  ),
];

void main() {
  declareTest(
    'Middleware: common behavior on implicit matcher',
    middlewareImplicit,
    _runTestCommon,
  );
  declareTest(
    'Middleware: common behavior on explicit matcher',
    middlewareExplicit,
    _runTestCommon,
  );

  declareTest(
    'Middleware: implicit matching behavior',
    middlewareImplicit,
    _runTestImplicit,
  );
  declareTest(
    'Middleware explicit matching behavior',
    middlewareExplicit,
    _runTestExplicit,
  );
}

FutureOr<void> _runTestCommon() async {
  final client = Find<Api>().find().connectHttp11();

  expect(await client.get('/test').thenGetJsonBody(), equals({'result': 'ok'}));
  expect(
    await client
        .get(
          '/middleware/test',
          headers: {
            'X-API-KEY': ['CORRECT-KEY'],
          },
        )
        .thenGetJsonBody(),
    equals({'result': 'ok'}),
  );

  expect(
    await client
        .get(
          '/middleware/other',
          headers: {
            'X-API-KEY': ['CORRECT-KEY'],
          },
        )
        .thenGetJsonBody(),
    equals({'result': 'ok'}),
  );

  expect(
    () => client
        .get(
          '/middleware/other',
          headers: {
            'X-API-KEY': ['WRONG-KEY'],
          },
        )
        .thenGetJsonBody(),
    throwsA(
      isA<ApiRequestException>().having((e) => e.statusCode, 'statusCode', 401),
    ),
  );

  expect(
    () => client.get('/middleware/other').thenGetJsonBody(),
    throwsA(
      isA<ApiRequestException>().having((e) => e.statusCode, 'statusCode', 401),
    ),
  );

  expect(
    () => client
        .get(
          '/middleware/nothing',
          headers: {
            'X-API-KEY': ['CORRECT-KEY'],
          },
        )
        .thenGetJsonBody(),
    throwsA(
      isA<ApiRequestException>().having((e) => e.statusCode, 'statusCode', 404),
    ),
  );
}

Future<void> _runTestImplicit() async {
  final client = Find<Api>().find().connectHttp11();

  expect(
    () => client.get('/middleware/nothing').thenGetJsonBody(),
    throwsA(
      isA<ApiRequestException>().having((e) => e.statusCode, 'statusCode', 404),
    ),
  );
}

Future<void> _runTestExplicit() async {
  final client = Find<Api>().find().connectHttp11();

  expect(
    () => client.get('/middleware/nothing').thenGetJsonBody(),
    throwsA(
      isA<ApiRequestException>().having((e) => e.statusCode, 'statusCode', 401),
    ),
  );
}
