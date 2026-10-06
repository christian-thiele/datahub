import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

/// Counts of the request duration histogram, with their labels.
Future<List<Map<String, Object>>> _requestCounts() async {
  final groups = await Find<Telemetry>().find().scrapeMetrics();
  return groups
      .where((g) => g.name == 'api_request_duration_seconds')
      .expand((g) => g.samples)
      .where((s) => s.name == 'api_request_duration_seconds_count')
      .map((s) => {...s.labels, 'count': s.value})
      .toList();
}

Map<String, Object> _labels(
  String route,
  int status, {
  String errorType = '',
  int count = 1,
}) => {
  'http_request_method': 'GET',
  'http_route': route,
  'http_response_status_code': status.toString(),
  'error_type': errorType,
  'url_scheme': 'http',
  'count': count,
};

void main() {
  declareTest(
    'Request duration metric',
    [
      ApiService(
        port: Config.value(0),
        routes: [
          ApiEndpointDelegate(
            matcher: RoutePattern('/orders/{id}'),
            delegate: (request) async => switch (request.getRouteParam<String>(
              'id',
            )) {
              'invalid' => throw ApiRequestException.badRequest('Invalid.'),
              'unavailable' => throw ApiRequestException.serviceUnavailable(),
              'crash' => throw StateError('crash'),
              _ => ApiResponse.dynamic({'ok': true}),
            },
          ),
        ],
      ),
    ],
    () async {
      final client = Find<Api>().find().connectHttp11();
      for (final path in [
        '/orders/1',
        '/orders/2',
        '/orders/invalid',
        '/orders/unavailable',
        '/orders/crash',
        '/missing',
      ]) {
        await client.get(path, throwOnError: false);
      }

      expect(
        await _requestCounts(),
        unorderedEquals([
          _labels('/orders/{id}', 200, count: 2),
          _labels('/orders/{id}', 400),
          _labels('/orders/{id}', 503, errorType: '503'),
          _labels('/orders/{id}', 500, errorType: 'StateError'),
          _labels('', 404),
        ]),
      );
    },
    tags: ['api'],
  );

  declareTest(
    'Request duration metric for rejected requests',
    [
      ApiService(
        port: Config.value(0),
        concurrentRequestLimit: Config.value(0),
        routes: [
          ApiEndpointDelegate(
            matcher: RoutePattern('/orders/{id}'),
            delegate: (request) async => ApiResponse.dynamic({'ok': true}),
          ),
        ],
      ),
    ],
    () async {
      await Find<Api>().find().connectHttp11().get(
        '/orders/1',
        throwOnError: false,
      );

      // rejected before routing
      expect(
        await _requestCounts(),
        equals([_labels('', 503, errorType: '503')]),
      );
    },
    tags: ['api'],
  );
}
