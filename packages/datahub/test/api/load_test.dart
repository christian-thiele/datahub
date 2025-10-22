import 'dart:io';
import 'dart:isolate';

import 'package:datahub/api.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/test.dart';

import 'lib/load_client.dart';

void main() {
  declareTest(
    'Mainthred Overload',
    [
      ApiService(routes: [ResourceEndpoint(get: (request) {
        sleep(const Duration(milliseconds: 5));
        sleep(const Duration(milliseconds: 5));
        sleep(const Duration(milliseconds: 5));
      })]),
    ],
    () async {
      await Isolate.run(() async {
        final client = await RestClient.connect(
          Uri.parse('http://localhost:8080'),
        );
        await LoadClient(
          client,
          () => client.get('/'),
        ).run(100, Duration(seconds: 10));
      });
    },
    timeout: Timeout(Duration(minutes: 10)),
  );
}
