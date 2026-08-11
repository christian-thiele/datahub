import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/expect.dart';

void main() {
  final release = Completer<void>();

  declareTest(
    'Concurrent request limit',
    [
      ApiService(
        port: Config.value(0),
        concurrentRequestLimit: Config.value(2),
        routes: [
          ApiEndpointDelegate(
            matcher: RoutePattern('/blocking'),
            delegate: (request) async {
              await release.future;
              return ApiResponse.dynamic({'ok': true});
            },
          ),
        ],
      ),
    ],
    () async {
      final client = Find<Api>().find().connectHttp11();
      final telemetry = Find<Telemetry>().find();

      Future<num> scrapeMetric(String name) async {
        final groups = await telemetry.scrapeMetrics();
        return groups.firstWhere((g) => g.name == name).samples.single.value;
      }

      // occupy the service up to the limit
      final first = client.get('/blocking').thenGetJsonBody();
      final second = client.get('/blocking').thenGetJsonBody();
      await Future.delayed(const Duration(milliseconds: 200));

      expect(await scrapeMetric('api_active_requests'), equals(2));
      expect(await scrapeMetric('api_requests_rejected'), equals(0));

      // over the limit: must be rejected with 503 instead of being served
      await expectLater(
        () => client.get('/blocking'),
        throwsA(
          isA<ApiRequestException>().having(
            (e) => e.statusCode,
            'statusCode',
            equals(503),
          ),
        ),
      );

      expect(await scrapeMetric('api_requests_rejected'), equals(1));

      // requests within the limit are served normally
      release.complete();
      expect(await first, equals({'ok': true}));
      expect(await second, equals({'ok': true}));

      // capacity is available again after requests complete
      expect(await scrapeMetric('api_active_requests'), equals(0));
      expect(
        await client.get('/blocking').thenGetJsonBody(),
        equals({'ok': true}),
      );
    },
  );
}
