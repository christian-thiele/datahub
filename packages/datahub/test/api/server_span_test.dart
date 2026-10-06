import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

void main() {
  LocalSpan? serverSpan;

  /// Remembers the server span of the request being handled.
  void captureSpan() {
    serverSpan =
        Find<Telemetry>().find().getDefaultTracer().findParentSpan()
            as LocalSpan;
  }

  declareTest(
    'Server span attributes',
    [
      ApiService(
        port: Config.value(0),
        routes: [
          ApiEndpointDelegate(
            matcher: RoutePattern('/orders/{id}'),
            delegate: (request) async {
              captureSpan();
              return switch (request.getRouteParam<String>('id')) {
                'invalid' => throw ApiRequestException.badRequest('Invalid.'),
                'unavailable' => throw ApiRequestException.serviceUnavailable(),
                'crash' => throw StateError('crash'),
                'gateway' => TextResponse.plain('bad', statusCode: 502),
                _ => ApiResponse.dynamic({'ok': true}),
              };
            },
          ),
        ],
      ),
    ],
    () async {
      final client = Find<Api>().find().connectHttp11();

      Future<LocalSpan> request(String id) async {
        serverSpan = null;
        await client.get('/orders/$id', throwOnError: false);
        return serverSpan!;
      }

      final ok = await request('42');
      expect(ok.name, equals('GET /orders/{id}'));
      expect(ok.type, equals(SpanType.server));
      expect(
        ok.attributes,
        equals({
          'http.request.method': 'GET',
          'http.route': '/orders/{id}',
          'url.path': '/orders/42',
          'url.scheme': 'http',
          'http.response.status_code': 200,
        }),
      );
      expect(ok.hasError, isFalse);

      // client errors are recorded, but do not fail the span
      final invalid = await request('invalid');
      expect(invalid.attributes['http.response.status_code'], equals(400));
      expect(invalid.attributes, isNot(contains('error.type')));
      expect(invalid.hasError, isFalse);
      expect(invalid.events, hasLength(1));

      final unavailable = await request('unavailable');
      expect(unavailable.attributes['http.response.status_code'], equals(503));
      expect(unavailable.attributes['error.type'], equals('503'));
      expect(unavailable.hasError, isTrue);

      final crash = await request('crash');
      expect(crash.attributes['http.response.status_code'], equals(500));
      expect(crash.attributes['error.type'], equals('StateError'));
      expect(crash.hasError, isTrue);

      final gateway = await request('gateway');
      expect(gateway.attributes['http.response.status_code'], equals(502));
      expect(gateway.attributes['error.type'], equals('502'));
      expect(gateway.hasError, isTrue);
    },
    tags: ['api'],
  );
}
