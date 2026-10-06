import 'dart:convert';

import 'package:datahub/datahub.dart';
import 'package:datahub/src/http/utils.dart';
import 'package:datahub/test.dart';
import 'package:http2/http2.dart' as http2;
import 'package:test/test.dart';

void main() {
  group('http2Headers', () {
    test('keeps each header field as one value', () {
      final (pseudoHeaders, headers) = http2Headers([
        http2.Header.ascii(':method', 'POST'),
        http2.Header.ascii(':path', '/test'),
        http2.Header.ascii('content-type', 'application/json;charset=UTF-8'),
        http2.Header.ascii('accept', 'text/html, application/json;q=0.9'),
        http2.Header.ascii('x-repeated', 'a'),
        http2.Header.ascii('x-repeated', 'b;c'),
      ]);

      expect(pseudoHeaders, equals({':method': 'POST', ':path': '/test'}));
      expect(
        headers,
        equals({
          'content-type': ['application/json;charset=UTF-8'],
          'accept': ['text/html, application/json;q=0.9'],
          'x-repeated': ['a', 'b;c'],
        }),
      );
    });

    test('concatenates cookie fields', () {
      final (_, headers) = http2Headers([
        http2.Header.ascii('cookie', 'a=1'),
        http2.Header.ascii('cookie', 'b=2; c=3'),
      ]);

      expect(
        headers,
        equals({
          'cookie': ['a=1; b=2; c=3'],
        }),
      );
    });
  });

  group('getEncodingFromHeaders', () {
    Encoding? encoding(String contentType) => getEncodingFromHeaders({
      HttpHeaders.contentType: [contentType],
    });

    test('reads the charset parameter', () {
      expect(encoding('application/json;charset=UTF-8'), equals(utf8));
      expect(encoding('text/plain; charset=iso-8859-1'), equals(latin1));
      expect(encoding('text/plain; Charset="utf-8"'), equals(utf8));
      expect(encoding('text/plain; format=flowed; charset=ascii'), ascii);
    });

    test('returns null without a known charset', () {
      expect(encoding('application/json'), isNull);
      expect(encoding('text/plain; charset=unknown'), isNull);
      expect(encoding('text/plain; x-charset=utf-8'), isNull);
      expect(getEncodingFromHeaders({}), isNull);
    });
  });

  declareTest(
    'Header values over HTTP/1.1 and HTTP/2',
    [
      ApiService(
        port: Config.value(0),
        routes: [
          ApiEndpointDelegate(
            matcher: RoutePattern('/headers'),
            delegate: (request) async {
              await request.getTextBody();
              return ApiResponse.dynamic({
                'contentType': request.headers[HttpHeaders.contentType],
                'charset': getEncodingFromHeaders(request.headers)?.name,
              });
            },
          ),
        ],
      ),
    ],
    () async {
      final api = Find<Api>().find();
      for (final client in [api.connectHttp11(), api.connectHttp2()]) {
        final response = await client.post('/headers', {'a': 1});

        // as seen by the server
        expect(
          await response.getJsonBody(),
          equals({
            'contentType': ['application/json;charset=UTF-8'],
            'charset': 'utf-8',
          }),
        );

        // as seen by the client
        expect(
          response.headers[HttpHeaders.contentType],
          equals(['application/json;charset=utf-8']),
        );
        expect(response.charset, equals(utf8));
      }
    },
    tags: ['api'],
  );
}
