import 'package:datahub/rest_client.dart';
import 'package:datahub/src/test/matchers.dart';
import 'package:test/test.dart';

import 'example_object.dart';

final uri = Uri.parse('https://httpbin.org/');
final prefixUri = Uri.parse('https://httpbin.org/status');
final prefixUri2 = Uri.parse('https://httpbin.org/status/');

void main() {
  group('REST Client', () {
    test('REST via HTTP 1.1', _testHttp11);
    test('REST via HTTP 2', _testHttp2);
    test('REST via RestClient.connect', _testConnect);
    test('REST with Path Prefix 1', () => _testPrefix(prefixUri));
    test('REST with Path Prefix 2', () => _testPrefix(prefixUri2));
  });
}

Future<void> _testHttp11() async {
  final client = RestClient.connectHttp11(uri);
  try {
    await _testClient(client);
  } finally {
    await client.close();
  }
}

Future<void> _testHttp2() async {
  final client = RestClient.connectHttp2(uri);
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

Future<void> _testPrefix(Uri uri) async {
  final client1 = await RestClient.connect(uri);
  try {
    expect(await client1.get('/404', throwOnError: false), hasStatusCode(equals(404)));
    expect(await client1.post('/500', null, throwOnError: false), hasStatusCode(equals(500)));
    expect(await client1.patch('/200', null, throwOnError: false), hasStatusCode(equals(200)));
    expect(await client1.delete('/200', throwOnError: false), hasStatusCode(equals(200)));
  } finally {
    await client1.close();
  }
}
