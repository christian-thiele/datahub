import 'dart:io';

import 'package:datahub/datahub.dart';

class LoadClient {
  final RestClient client;
  Future<RestResponse> Function() request;

  LoadClient(this.client, this.request);

  Future<void> run(int rate, Duration duration) async {
    final requestCount = duration.inSeconds * rate;
    final requests = <Future>[];
    final responses = <dynamic>[];

    String n(int number) => number.toString().padLeft(4, ' ');

    void notify() {
      final successCount = responses
          .where((e) => e.statusCode >= 200 && e.statusCode < 300)
          .length;
      final failedCount = responses.length - successCount;
      final pendingCount = requests.length - responses.length;
      log.info(
        '\rSUCCESS: ${n(successCount)} FAIL: ${n(failedCount)} IN-FLIGHT: ${n(pendingCount)}',
      );
    }

    for (final _ in Iterable.generate(requestCount)) {
      final sw = Stopwatch()..start();
      requests.add(
        request()
            .then((r) {
              responses.add(r);
              notify();
            })
            .onError<ApiRequestException>((e, _) {
              responses.add(e);
              notify();
            }),
      );
      notify();
      sw.stop();
      await Future.delayed(
        Duration(milliseconds: (1000 / rate - sw.elapsedMilliseconds).floor()),
      );
    }
    await Future.wait(requests);
    notify();
  }
}
