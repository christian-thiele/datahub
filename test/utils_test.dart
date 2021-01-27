import 'package:test/test.dart';
import 'package:boost/boost.dart';

import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/utils.dart';

void main() {
  test('Route encode', _testRouteEncode);
  test('Route match', _testRouteMatch);
  test('Route decode', _testRouteDecode);
}

void _testRouteEncode() {
  final pattern1 = '/path/to/{stuff}/articles/article_{articleId}';
  final args1 = {'stuff': 'some', 'articleId': 328};
  final route1 = encodeRoute(pattern1, args1);
  expect(route1, equals('/path/to/some/articles/article_328'));
}

void _testRouteMatch() {
  final pattern1 = '/path/to/{stuff}/articles/article_{articleId}';
  final route1 = '/path/to/some/articles/article_328';
  final route2 = '/path/to/some/articles/article';
  final route3 = '/path/to/some/ArTiClEs/article_1';
  final route4 = '/path/to/some/articles/article_';
  final route5 = '/path/to/some/ArTiClEs/article_';
  final route6 = '/path/to/articles/article_1';
  final route7 = '/path/to//articles/article_1';

  expect(matchRoute(pattern1, route1), isTrue);
  expect(matchRoute(pattern1, route2), isFalse);
  expect(matchRoute(pattern1, route3), isTrue);
  expect(matchRoute(pattern1, route4), isFalse);
  expect(matchRoute(pattern1, route5), isFalse);
  expect(matchRoute(pattern1, route6), isFalse);
  expect(matchRoute(pattern1, route7), isFalse);
}

void _testRouteDecode() {
  final pattern1 = '/path/to/{stuff}/articles/article_{articleId}';
  final routes = [
    '/path/to/some/articles/article_328',
    '/path/to/some/articles/article',
    '/path/to/some/ArTiClEs/article_1',
    '/path/to/some/articles/article_',
    '/path/to/some/ArTiClEs/article_',
    '/path/to/articles/article_1',
    '/path/to//articles/article_1'
  ];

  final expectedResults = [
    {'stuff': 'some', 'articleId': '328'},
    null,
    {'stuff': 'some', 'articleId': '1'},
    null,
    null,
    null,
    null,
  ];

  final tests = routes.zip(expectedResults);

  for(final test in tests) {
    if (test.b == null) {
      expect(() => decodeRoute(pattern1, test.a!), throwsA(isA<ApiException>()));
    }else{
      final result = decodeRoute(pattern1, test.a!);
      expect(result, equals(test.b));
    }
  }
}
