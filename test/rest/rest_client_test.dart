import 'package:datahub/http.dart';
import 'package:datahub/rest_client.dart';
import 'package:test/test.dart';

import 'example_object.dart';

final uri = Uri.parse('https://httpbin.org/');

void main() {
  group('REST Client', () {
    test('REST via HTTP 1.1', _testHttp11);
    test('REST via HTTP 2', _testHttp2);
    test('REST via RestClient.connect', _testConnect);
  });
}

Future<void> _testHttp11() async {
  final httpClient = HttpClient.http11(uri);
  final client = RestClient(httpClient);
  try {
    await _testClient(client);
  } finally {
    await client.close();
  }
}

Future<void> _testHttp2() async {
  final httpClient = HttpClient.http2(uri);
  final client = RestClient(httpClient);
  try {
    await _testClient(client);
  } finally {
    await client.close();
  }
}

Future<void> _testConnect() async {
  final client = await RestClient.connect(uri);
  try {
    await _testClient(client);
  } finally {
    await client.close();
  }
}

Future<void> _testClient(RestClient client) async {
  final text = await client.get('/html').thenGetTextBody();
  expect(text, contains('<html>'));

  final dto =
      await client.get('/json').thenGetBody(bean: ExampleObjectTransferBean);
  expect(dto.slideshow.author, equals('Yours Truly'));
  expect(dto.slideshow.date, equals('date of publication'));
  expect(dto.slideshow.title, equals('Sample Slide Show'));

  final stream = await client.get('/drip', query: {
    'numbytes': ['5'],
    'duration': ['1']
  }).thenGetBodyData();
  expect(await stream.expand((element) => element).toList(), hasLength(5));
}
