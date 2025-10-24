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
            matcher: RoutePattern('/action'),
            post: (request) async {
              await Future.delayed(const Duration(milliseconds: 100));
              await Find<Telemetry>().find().trace('wait', (span) async {
                span.addEvent('something happens here');
                await Future.delayed(const Duration(milliseconds: 400));
                if (request.getParam<bool>('fail') == true) {
                  throw ApiRequestException(
                    500,
                    'Request failed intentionally.',
                  );
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

      for (final i in Iterable.generate(5)) {
        await client.post(
          '/action',
          {},
          query: {
            'fail': [i < 3 ? 'true' : 'false'],
          },
          throwOnError: false,
        );
      }
    },
    timeout: Timeout.none,
  );
}
