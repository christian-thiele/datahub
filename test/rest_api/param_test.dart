import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

void main() {
  group('Query Parameters', () {
    test('String', _queryString);
    test('int', _queryInt);
    test('DateTime', _queryDateTime);
    test('List<String>', _queryStringList);
    test('List<int>', _queryIntList);
  });
}

ApiRequest _request(String url) {
  final uri = Uri.parse(url);
  return ApiRequest(
    ApiRequestMethod.GET,
    RoutePattern.any.decode(uri.path),
    {},
    uri.queryParametersAll,
    Stream.empty(),
    null,
  );
}

void _queryString() {
  expect(_request('http://localhost/?abc=123').getParam<String>('abc'), '123');
  expect(_request('http://localhost/?abc=def').getParam<String?>('abc'), 'def');
  expect(
      _request('http://localhost/?abc=hi%20there').getParam('abc'), 'hi there');
  expect(_request('http://localhost/?abc=123').getParam<String?>('abd'), null);
  expect(() => _request('http://localhost/?abc=123').getParam<String>('abd'),
      throwsException);
}

void _queryInt() {
  expect(_request('http://localhost/?abc=123').getParam<int>('abc'), 123);
  expect(_request('http://localhost/?abc=123').getParam<int>('abc'), 123);
  expect(_request('http://localhost/?abc=123').getParam<int?>('abd'), null);
  expect(() => _request('http://localhost/?abc=123').getParam<int>('abd'),
      throwsException);
}

void _queryDateTime() {
  expect(
      _request(
              'http://localhost/?timestamp=2023-06-01T10%3A20%3A00.000%2B02%3A00')
          .getParam<DateTime>('timestamp'),
      DateTime.utc(2023, 06, 01, 8, 20, 0));
  // these tests only works if run in utc timezone (bc query string is local)
  //expect(_request('http://localhost/?timestamp=2023-06-01T08%3A20%3A00.000').getParam<DateTime>('timestamp'), DateTime.utc(2023, 06, 01, 8, 20, 0).toUtc());
  //expect(_request('http://localhost/?timestamp=2023-06-01').getParam<DateTime>('timestamp'), DateTime.utc(2023, 06, 01));
  expect(
      _request('http://localhost/?timestamp=1688546106000')
          .getParam<DateTime>('timestamp')
          .toUtc(),
      DateTime.utc(2023, 07, 05, 8, 35, 6));
}

void _queryStringList() {
  expect(
      _request(
              'http://localhost/?list=first&list=second&list=third&other=other')
          .getParam<List<String>>('list'),
      ['first', 'second', 'third']);
  expect(
      _request(
              'http://localhost/?list=first&list=second&list=third&other=other')
          .getParam<List<String>?>('list2'),
      null);
  expect(
      _request(
              'http://localhost/?list=first&list=second&list=third&other=other')
          .getParam<List<String>?>('other'),
      ['other']);
}

void _queryIntList() {
  expect(
      _request('http://localhost/?list=2&list=4&list=6&other=8')
          .getParam<List<int>>('list'),
      [2, 4, 6]);
  expect(
      _request('http://localhost/?list=2&list=4&list=6&other=8')
          .getParam<List<int>?>('list2'),
      null);
  expect(
      _request('http://localhost/?list=2&list=4&list=6&other=8')
          .getParam<List<int>?>('other'),
      [8]);
}
