import 'dart:math';

import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/test.dart';

void main() {
  const port = 8001;
  declareTest(
    'Trace API Requests',
    [
      ApiService(
        routes: [
          ResourceEndpoint(
            matcher: RoutePattern('/slow'),
            post: (request) async {
              await Future.delayed(const Duration(seconds: 2));
              Find<Telemetry>().find().addEvent('something happens here');
              await Future.delayed(const Duration(seconds: 3));
              return {'status': 'ok'};
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern('/fast'),
            post: (request) async {
              await Future.delayed(const Duration(milliseconds: 100));
              await Find<Telemetry>().find().trace('wait', (span) async {
                span.addEvent('something happens here');
                await Future.delayed(const Duration(milliseconds: 400));
                if (Random().nextBool()) {
                  throw ApiRequestException(500, 'NOPE');
                }
              });
              return {'status': 'ok'};
            },
          ),
        ],
        port: Config.value(port),
      ),
    ],
    config: {
      'telemetry': {
        'serviceName': 'unit-test',
        'openTelemetryExporter': {'enable': true, 'host': '192.168.178.85'},
      },
    },
    () async {
      final client = await RestClient.connect(
        Uri.parse('http://localhost:$port'),
      );

      for (final _ in Iterable.generate(5)) {
        await client.post('/slow', {}, throwOnError: false);
      }

      for (final _ in Iterable.generate(5)) {
        await client.post('/fast', {}, throwOnError: false);
      }
    },
    timeout: Timeout.none,
  );
}
