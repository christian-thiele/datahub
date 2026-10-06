import 'dart:convert';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

void main() {
  declareTest(
    'Test prometheus metrics endpoint',
    [],
    () async {
      final uri = Uri(
        scheme: 'http',
        host: '127.0.0.1',
        port: 9090,
        path: '/metrics',
      );
      final client = HttpClient.http11(uri);
      final response = await client.request(
        HttpRequest(HttpRequestMethod.get, uri, {}, Stream.empty()),
      );
      expect(response.statusCode, equals(200));
      expect(
        response.headers[HttpHeaders.contentType],
        unorderedEquals(['text/plain; version=0.0.4; charset=utf-8']),
      );
    },
    config: {
      'telemetry': {
        'prometheusExporter': {'enable': true},
      },
    },
  );

  declareTest(
    'Test prometheus label values are escaped',
    [],
    () async {
      final telemetry = Find<Telemetry>().find();
      telemetry
          .exponentialHistogram(
            'escaped',
            start: 1,
            factor: 2,
            count: 1,
            labelNames: {'value'},
          )
          .observe(1, {'value': 'a"b\\c\nd'});

      final uri = Uri(
        scheme: 'http',
        host: '127.0.0.1',
        port: 9090,
        path: '/metrics',
      );
      final response = await HttpClient.http11(
        uri,
      ).request(HttpRequest(HttpRequestMethod.get, uri, {}, Stream.empty()));
      final body = await response.bodyData
          .transform(const Utf8Decoder())
          .join();

      expect(body, contains(r'escaped_count{value="a\"b\\c\nd"} 1'));
      // no timestamps
      expect(
        body,
        contains(RegExp(r'^escaped_count\{[^\n]*\} 1$', multiLine: true)),
      );
    },
    config: {
      'telemetry': {
        'prometheusExporter': {'enable': true},
      },
    },
  );

  declareTest(
    'Test prometheus scrapes are not traced',
    [],
    () async {
      final servers = <LocalSpan>[];
      final subscription = Find<Telemetry>()
          .find()
          .endedSpans
          .where((s) => s.type == SpanType.server)
          .listen(servers.add);

      final uri = Uri(
        scheme: 'http',
        host: '127.0.0.1',
        port: 9090,
        path: '/metrics',
      );
      final response = await HttpClient.http11(
        uri,
      ).request(HttpRequest(HttpRequestMethod.get, uri, {}, Stream.empty()));
      await response.bodyData.drain();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(servers, isEmpty);
      await subscription.cancel();
    },
    config: {
      'telemetry': {
        'prometheusExporter': {'enable': true},
      },
    },
  );
}
