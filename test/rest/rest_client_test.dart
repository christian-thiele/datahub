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
  final httpClient = await HttpClient.http11(uri);
  final client = RestClient(httpClient);
  try {
    await _testClient(client);
  } finally {
    await client.close();
  }
}

Future<void> _testHttp2() async {
  final httpClient = await HttpClient.http2(uri);
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
  final text = await client.getObject<String>('/html');
  text.throwOnError();
  expect(text.data, contains('<html>'));

  final dto = await client.getObject('/json', bean: ExampleObjectTransferBean);
  dto.throwOnError();
  expect(dto.data.slideshow.author, equals('Yours Truly'));
  expect(dto.data.slideshow.date, equals('date of publication'));
  expect(dto.data.slideshow.title, equals('Sample Slide Show'));

  final stream = await client.getObject<Stream<List<int>>>('/drip',
      query: {'numbytes': '5', 'duration': '1'});
  stream.throwOnError();
  expect(await stream.data.expand((element) => element).toList(), hasLength(5));
}
