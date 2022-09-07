import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:test/test.dart';

final website = Uri.parse('https://datahubproject.net');

void main() {
  group('HTTP Client', () {
    test('Simple HTTP 1.1', _testHttp11);
    test('Simple HTTP 2', _testHttp2);
  });
}

Future<void> _testHttp11() async {
  final httpClient = await HttpClient.http11(website);
  await _testClient(httpClient);
}

Future<void> _testHttp2() async {
  final httpClient = await HttpClient.http2(website);
  await _testClient(httpClient);
}

Future<void> _testClient(HttpClient httpClient) async {
  final response = await httpClient.request(HttpRequest(
    ApiRequestMethod.GET,
    website,
    {},
    Stream.empty(),
  ));

  Encoding encoding = utf8;
  if (response.headers.containsKey('content-type')) {
    final charsetMatch = RegExp('charset=([^;,]+)')
        .firstMatch(response.headers['content-type']!.first);
    if (charsetMatch != null) {
      encoding = Encoding.getByName(charsetMatch.group(1)!) ?? encoding;
    }
  }

  final content = await encoding.decodeStream(response.bodyData);

  expect(response.statusCode, equals(200));
  expect(response.requestUrl, equals(website));
  expect(content.length, greaterThan(10));
}
