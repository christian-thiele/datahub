import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

void main() {
  test('Graceful shutdown drains active requests', () async {
    final release = Completer<void>();
    final host = TestHost(
      components: [
        ApiService(
          port: Config.value(0),
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
      testBody: () {},
    );

    await host.initialize();
    final client = host.findComponent(Find<Api>(), null).connectHttp11();

    // occupy the service with an active request
    final blocked = client.get('/blocking').thenGetJsonBody();
    await Future.delayed(const Duration(milliseconds: 200));

    var shutdownComplete = false;
    final shutdown = host.shutdown().whenComplete(() {
      shutdownComplete = true;
    });
    await Future.delayed(const Duration(milliseconds: 200));

    // while draining, new connections are no longer accepted
    await expectLater(client.get('/blocking'), throwsA(anything));

    // shutdown waits for the active request, which completes normally
    expect(shutdownComplete, isFalse);
    release.complete();
    expect(await blocked, equals({'ok': true}));
    await shutdown;
    expect(shutdownComplete, isTrue);
  });
}
