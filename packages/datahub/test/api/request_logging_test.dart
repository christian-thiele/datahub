import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:datahub/datahub.dart';
import 'package:datahub/src/api/request_logger.dart';
import 'package:datahub/test.dart';
import 'package:test/expect.dart';
import 'package:web_socket/web_socket.dart';

final _uri = Uri.parse('/orders');

HttpRequest _request(
  String uri, {
  HttpRequestMethod method = HttpRequestMethod.get,
  Map<String, List<String>> headers = const {},
  String? body,
}) => HttpRequest(
  method,
  Uri.parse(uri),
  headers,
  body == null ? const Stream.empty() : Stream.value(utf8.encode(body)),
);

/// Runs [request] through [logger] within a span and consumes the response
/// body outside of it, like the HTTP server does.
Future<(List<LogMessage>, List<int>)> _exchange(
  RequestLogger logger,
  HttpRequest request,
  HttpRequestHandler handler,
) async {
  final logs = <LogMessage>[];
  final body = await LogListener(onPublish: logs.add).run(() async {
    final response = await Find<Telemetry>().find().trace(
      'HTTP',
      (_) => logger.handle(request, handler),
    );
    return await response.bodyData.expand((e) => e).toList();
  });

  expect(logs, hasLength(2));
  expect(logs.map((e) => e.level), everyElement(SeverityLevel.trace));
  expect(logs[0].span, isNotNull);
  expect(logs[1].span?.spanId, equals(logs[0].span!.spanId));
  expect(
    logs[0].labels,
    containsPair('event.name', 'http.server.request.received'),
  );
  expect(
    logs[1].labels,
    containsPair('event.name', 'http.server.response.sent'),
  );

  return (logs, body);
}

void main() {
  declareTest('Request logging', [], () async {
    final logger = RequestLogger(bodyLimit: 16);

    // request and response records
    {
      final (logs, body) = await _exchange(
        logger,
        _request(
          '/orders?page=1&access_token=secret-token',
          method: HttpRequestMethod.post,
          headers: {
            HttpHeaders.contentType: [Mime.json],
            HttpHeaders.contentLength: ['14'],
            HttpHeaders.authorization: ['Bearer secret-token'],
            'x-multi': ['a', 'b'],
          },
          body: '{"item":"abc"}',
        ),
        (request) async {
          expect(
            await request.bodyData.expand((e) => e).toList(),
            equals(utf8.encode('{"item":"abc"}')),
          );
          return JsonResponse({'id': 1}, statusCode: 201).toHttpResponse(_uri);
        },
      );

      expect(utf8.decode(body), equals('{"id":1}'));
      for (final log in logs) {
        expect(log.line, isNot(contains('secret')));
        expect(log.labels.values, everyElement(isNot(contains('secret'))));
      }

      expect(
        logs[0].line,
        equals('Request received: POST /orders?page=1&access_token=REDACTED'),
      );
      expect(
        logs[0].labels,
        equals({
          'event.name': 'http.server.request.received',
          'http.request.method': 'POST',
          'url.path': '/orders',
          'url.query': 'page=1&access_token=REDACTED',
          'http.request.header.content-type': 'application/json',
          'http.request.header.content-length': '14',
          'http.request.header.authorization': 'Bearer REDACTED',
          'http.request.header.x-multi': 'a, b',
        }),
      );

      expect(
        logs[1].line,
        matches(
          RegExp(
            r'^Response sent: 201 for POST /orders\?page=1&access_token=REDACTED '
            r'in \d+\.\d ms$',
          ),
        ),
      );
      expect(
        double.parse(logs[1].labels['http.server.request.duration']!),
        greaterThan(0),
      );
      expect(
        logs[1].labels..remove('http.server.request.duration'),
        equals({
          'event.name': 'http.server.response.sent',
          'http.request.method': 'POST',
          'url.path': '/orders',
          'url.query': 'page=1&access_token=REDACTED',
          'http.response.status_code': '201',
          'http.request.body.size': '14',
          'http.request.body.content': '{"item":"abc"}',
          'http.response.body.size': '8',
          'http.response.body.content': '{"id":1}',
          'http.response.header.content-type': 'application/json;charset=utf-8',
        }),
      );
    }

    // large bodies are truncated, but sent completely
    {
      final (logs, body) = await _exchange(
        logger,
        _request('/large'),
        (request) async => TextResponse.plain('x' * 100).toHttpResponse(_uri),
      );

      expect(body, hasLength(100));
      expect(
        logs[1].labels,
        allOf(
          containsPair('http.response.body.size', '100'),
          containsPair('http.response.body.content', 'x' * 16),
          containsPair('http.response.body.truncated', 'true'),
        ),
      );
    }

    // binary bodies are logged with their size only
    {
      final (logs, _) = await _exchange(
        logger,
        _request('/binary'),
        (request) async => RawResponse(Uint8List(64)).toHttpResponse(_uri),
      );

      expect(logs[1].labels, containsPair('http.response.body.size', '64'));
      expect(
        logs[1].labels.keys,
        isNot(contains(startsWith('http.response.body.content'))),
      );
    }

    // request bodies the handler did not read have no known size
    {
      final (logs, _) = await _exchange(
        logger,
        _request(
          '/ignored',
          method: HttpRequestMethod.post,
          headers: {
            HttpHeaders.contentLength: ['5'],
          },
          body: 'hello',
        ),
        (request) async => EmptyResponse().toHttpResponse(_uri),
      );

      expect(
        logs[1].labels.keys,
        isNot(contains(startsWith('http.request.body'))),
      );
      expect(logs[1].labels, containsPair('http.response.body.size', '0'));
    }

    // control characters cannot forge log lines or escape sequences
    {
      final (logs, _) = await _exchange(
        logger,
        _request(
          '/escape',
          headers: {
            'x-test': ['a\nResponse sent: 200 for GET /forged'],
          },
        ),
        (request) async =>
            TextResponse.plain('\u001b[31mred\r\nline').toHttpResponse(_uri),
      );

      expect(
        logs[0].labels,
        containsPair(
          'http.request.header.x-test',
          r'a\nResponse sent: 200 for GET /forged',
        ),
      );
      expect(
        logs[1].labels,
        containsPair(
          'http.response.body.content',
          r'\u001b[31mred\r'
              '\nline',
        ),
      );
    }

    // additionally redacted headers
    {
      final (logs, _) = await _exchange(
        RequestLogger(bodyLimit: 16, redactedHeaders: ['X-Tenant-Token']),
        _request(
          '/tenant',
          headers: {
            'x-tenant-token': ['secret-token'],
            HttpHeaders.authorization: ['Basic secret-token'],
          },
        ),
        (request) async => HttpResponse(_uri, 200, {
          'X-Tenant-Token': ['secret-token'],
        }, const Stream.empty()),
      );

      expect(
        logs[0].labels,
        allOf(
          containsPair('http.request.header.x-tenant-token', 'REDACTED'),
          containsPair('http.request.header.authorization', 'Basic REDACTED'),
        ),
      );
      expect(
        logs[1].labels,
        containsPair('http.response.header.x-tenant-token', 'REDACTED'),
      );
    }

    // body content can be disabled, sizes are still logged
    {
      final (logs, body) = await _exchange(
        RequestLogger(bodyLimit: 0),
        _request(
          '/no-content',
          method: HttpRequestMethod.post,
          headers: {
            HttpHeaders.contentType: [Mime.plainText],
          },
          body: 'hello',
        ),
        (request) async {
          await request.bodyData.drain<void>();
          return TextResponse.plain('x' * 100).toHttpResponse(_uri);
        },
      );

      expect(body, hasLength(100));
      expect(
        logs[1].labels,
        allOf(
          containsPair('http.request.body.size', '5'),
          containsPair('http.response.body.size', '100'),
        ),
      );
      expect(
        logs[1].labels.keys,
        isNot(
          anyElement(anyOf(endsWith('.body.content'), endsWith('.truncated'))),
        ),
      );
    }

    // responses the client stops receiving
    {
      final controller = StreamController<List<int>>();
      final logs = <LogMessage>[];
      await LogListener(onPublish: logs.add).run(() async {
        final response = await logger.handle(
          _request('/stream'),
          (request) async => HttpResponse(_uri, 200, {}, controller.stream),
        );

        final firstChunk = Completer<void>();
        final subscription = response.bodyData.listen(
          (_) => firstChunk.complete(),
        );
        controller.add(utf8.encode('abc'));
        await firstChunk.future;
        expect(logs, hasLength(1));
        await subscription.cancel();
      });

      expect(logs, hasLength(2));
      expect(
        logs[1].line,
        matches(r'^Response aborted: 200 for GET /stream after \d+\.\d ms$'),
      );
      expect(
        logs[1].labels,
        allOf(
          containsPair('event.name', 'http.server.response.aborted'),
          containsPair('error.type', 'aborted'),
          containsPair('http.response.body.size', '3'),
          containsPair('http.response.body.content', 'abc'),
        ),
      );
    }

    // responses failing while being sent
    {
      final logs = <LogMessage>[];
      await LogListener(onPublish: logs.add).run(() async {
        final response = await logger.handle(
          _request('/failing'),
          (request) async =>
              HttpResponse(_uri, 200, {}, Stream.error(StateError('failed'))),
        );
        await expectLater(response.bodyData.toList(), throwsStateError);
      });

      expect(logs, hasLength(2));
      expect(
        logs[1].line,
        matches(r'^Response failed: 200 for GET /failing after \d+\.\d ms$'),
      );
      expect(logs[1].error, isStateError);
      expect(
        logs[1].labels,
        allOf(
          containsPair('event.name', 'http.server.response.failed'),
          containsPair('error.type', 'StateError'),
        ),
      );
    }
  });

  declareTest(
    'ApiService with request logging',
    [
      ApiService(
        port: Config.value(0),
        logRequests: Config.value(true),
        logRequestsBodyLimit: Config.value(64),
        routes: [
          WebsocketEndpoint(
            matcher: RoutePattern('/ws'),
            onSession: (session) async {
              session.stream.listen((frame) {
                if (frame.opcode == WebsocketOpcode.text) {
                  session.sink.add(
                    WebsocketFrame.text(utf8.decode(frame.payload)),
                  );
                }
              });
            },
          ),
          ApiEndpointDelegate(
            matcher: RoutePattern('/echo'),
            delegate: (request) async =>
                ApiResponse.dynamic({'body': await request.getJsonBody()}),
          ),
        ],
      ),
    ],
    config: {
      'telemetry': {'logLevel': 'trace', 'logStdoutFormat': 'logfmt'},
    },
    () async {
      final api = Find<Api>().find();
      final payload = {'data': 'x' * 1000};

      for (final client in [api.connectHttp11(), api.connectHttp2()]) {
        expect(
          await client.post('/echo', payload).thenGetJsonBody(),
          equals({'body': payload}),
        );
      }

      final socket = await WebSocket.connect(
        Uri(scheme: 'ws', host: 'localhost', port: api.port, path: '/ws'),
      );
      socket.sendText('hello');
      expect(
        await socket.events.first,
        isA<TextDataReceived>().having((e) => e.text, 'text', 'hello'),
      );
      await socket.close();
    },
    tags: ['api'],
  );
}
