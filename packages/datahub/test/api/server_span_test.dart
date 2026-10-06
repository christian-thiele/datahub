import 'dart:io' as io;

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

/// Collects the spans that end while the test runs.
class _Spans {
  final spans = <LocalSpan>[];

  _Spans() {
    Find<Telemetry>().find().endedSpans.listen(spans.add);
  }

  Iterable<LocalSpan> get servers =>
      spans.where((s) => s.type == SpanType.server);

  /// Waits for the server span of [traceId], since the server may end it
  /// after the client received the response.
  Future<LocalSpan> serverOf(TraceId traceId) async {
    for (var i = 0; i < 100; i++) {
      final matching = servers.where((s) => s.traceId == traceId).toList();
      if (matching.isNotEmpty) {
        expect(matching, hasLength(1), reason: 'one server span per request');
        return matching.single;
      }
      await Future.delayed(const Duration(milliseconds: 20));
    }
    throw StateError('No server span for trace $traceId.');
  }

  /// Waits for the next server span.
  Future<LocalSpan> nextServer(int before) async {
    for (var i = 0; i < 100; i++) {
      if (servers.length > before) {
        return servers.last;
      }
      await Future.delayed(const Duration(milliseconds: 20));
    }
    throw StateError('No server span.');
  }
}

/// Requests [path] with `dart:io`, so no client span is created.
Future<int> _rawGet(int port, String path, {String? traceparent}) async {
  final client = io.HttpClient();
  try {
    final request = await client.get('127.0.0.1', port, path);
    if (traceparent != null) {
      request.headers.set('traceparent', traceparent);
    }
    final response = await request.close();
    await response.drain();
    return response.statusCode;
  } finally {
    client.close();
  }
}

void main() {
  declareTest(
    'Server span attributes',
    [
      ApiService(
        port: Config.value(0),
        routes: [
          ApiEndpointDelegate(
            matcher: RoutePattern('/orders/{id}'),
            delegate: (request) async {
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
      final spans = _Spans();
      final port = Find<Api>().find().port;

      Future<LocalSpan> request(String path) async {
        final before = spans.servers.length;
        await _rawGet(port, path);
        return await spans.nextServer(before);
      }

      final ok = await request('/orders/42');
      expect(ok.name, equals('GET /orders/{id}'));
      expect(ok.type, equals(SpanType.server));
      expect(
        ok.attributes,
        equals({
          'http.request.method': 'GET',
          'http.route': '/orders/{id}',
          'url.path': '/orders/42',
          'url.scheme': 'http',
          'network.protocol.version': '1.1',
          'server.port': port,
          'user_agent.original': ok.attributes['user_agent.original'],
          'http.response.status_code': 200,
        }),
      );
      expect(ok.attributes['user_agent.original'], startsWith('Dart/'));
      expect(ok.hasError, isFalse);

      // client errors are recorded, but do not fail the span
      final invalid = await request('/orders/invalid');
      expect(invalid.attributes['http.response.status_code'], equals(400));
      expect(invalid.attributes, isNot(contains('error.type')));
      expect(invalid.hasError, isFalse);
      expect(invalid.events.single.name, equals('exception'));

      final unavailable = await request('/orders/unavailable');
      expect(unavailable.attributes['http.response.status_code'], equals(503));
      expect(unavailable.attributes['error.type'], equals('503'));
      expect(unavailable.hasError, isTrue);

      final crash = await request('/orders/crash');
      expect(crash.attributes['http.response.status_code'], equals(500));
      expect(crash.attributes['error.type'], equals('StateError'));
      expect(crash.hasError, isTrue);
      expect(
        crash.events.single.attributes['exception.stacktrace'],
        isA<String>(),
      );

      final gateway = await request('/orders/gateway');
      expect(gateway.attributes['http.response.status_code'], equals(502));
      expect(gateway.attributes['error.type'], equals('502'));
      expect(gateway.hasError, isTrue);

      // without a route, the span is named after the method only
      final missing = await request('/missing');
      expect(missing.name, equals('GET'));
      expect(missing.attributes, isNot(contains('http.route')));
      expect(missing.attributes['http.response.status_code'], equals(404));
    },
    tags: ['api'],
  );

  declareTest(
    'Server spans continue the trace of the caller',
    [
      ApiService(
        port: Config.value(0),
        routes: [
          ApiEndpointDelegate(
            matcher: RoutePattern('/ping'),
            delegate: (request) async => ApiResponse.dynamic({'ok': true}),
          ),
        ],
      ),
    ],
    () async {
      final spans = _Spans();
      final api = Find<Api>().find();

      // incoming traceparent header
      const traceparent =
          '00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01';
      await _rawGet(api.port, '/ping', traceparent: traceparent);
      final remote = TraceContext.parse(traceparent)!;
      final continued = await spans.serverOf(remote.traceId);
      expect(continued.parentSpanId, equals(remote.spanId));

      // HttpClient propagates its client span
      final client = api.connectHttp11();
      await client.get('/ping');
      final clientSpan = spans.spans.lastWhere(
        (s) => s.type == SpanType.client,
      );
      expect(clientSpan.name, equals('GET'));
      expect(clientSpan.attributes['http.response.status_code'], equals(200));
      expect(clientSpan.attributes['url.full'], endsWith('/ping'));
      final server = await spans.serverOf(clientSpan.traceId);
      expect(server.parentSpanId, equals(clientSpan.spanId));
    },
    tags: ['api'],
  );

  declareTest('HttpServer traces requests without ApiService', [], () async {
    final spans = _Spans();
    final socket = await io.ServerSocket.bind('127.0.0.1', 0);
    final server = HttpServer(
      socket,
      (request) async =>
          HttpResponse(request.requestUri, 204, {}, const Stream.empty()),
      (_, _) {},
      (_, _) {},
      (_, _) {},
    );

    try {
      expect(await _rawGet(socket.port, '/plain'), equals(204));
      final span = await spans.nextServer(0);
      expect(span.name, equals('GET'));
      expect(span.attributes['url.path'], equals('/plain'));
      expect(span.attributes['http.response.status_code'], equals(204));
    } finally {
      await server.close(force: true);
    }
  }, tags: ['api']);
}
