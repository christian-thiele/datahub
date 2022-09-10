import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:datahub/src/http/utils.dart';
import 'package:test/test.dart';

final website = Uri.parse('https://datahubproject.net');

void main() {
  group('HTTP Client', () {
    test('Simple HTTP 1.1', _testHttp11);
    test('Simple HTTP 2', _testHttp2);
    test('Simple HTTP Autodetect', _testAuto);
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

Future<void> _testAuto() async {
  final httpClient = await HttpClient.autodetect(website);
  await _testClient(httpClient);
}

Future<void> _testClient(HttpClient httpClient) async {
  final response = await httpClient.request(HttpRequest(
    ApiRequestMethod.GET,
    website,
    {},
    Stream.empty(),
  ));

  final encoding = getEncodingFromHeaders(response.headers) ?? utf8;
  final content = await encoding.decodeStream(response.bodyData);

  expect(response.statusCode, equals(200));
  expect(response.requestUrl, equals(website));
  expect(content.length, greaterThan(10));
}
