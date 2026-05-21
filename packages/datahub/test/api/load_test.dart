import 'dart:io';
import 'dart:isolate';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

import 'lib/load_client.dart';

void main() {
  declareTest(
    'Mainthred Overload',
    [
      ApiService(
        port: Config.value(0),
        routes: [
          ResourceEndpoint(
            get: (request) async {
              sleep(const Duration(milliseconds: 50));
              await Future.delayed(const Duration(milliseconds: 10));
              sleep(const Duration(milliseconds: 50));
              await Future.delayed(const Duration(milliseconds: 10));
              sleep(const Duration(milliseconds: 50));
            },
          ),
        ],
      ),
    ],
    () async {
      final apiPort = Context.zoneFind(Find<Api>()).port;
      await Isolate.run(() async {
        final client = await RestClient.connect(
          Uri(scheme: 'http', host: '127.0.0.1', port: apiPort),
        );
        await LoadClient(
          client,
          () => client.get('/'),
        ).run(100, Duration(seconds: 10));
      });
    },
    timeout: Timeout(Duration(seconds: 15)),
    skip: true,
  );
}
