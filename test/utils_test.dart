import 'package:cl_datahub/src/api/api_error.dart';
import 'package:test/test.dart';
import 'package:boost/boost.dart';

import 'package:cl_datahub/api.dart';

void main() {
  test('Invalid pattern', _testRouteInvalid);
  test('isWildcardPattern', _testIsWildcard);
  test('Route encode', _testRouteEncode);
  test('Route match', _testRouteMatch);
  test('Route decode', _testRouteDecode);
}

final pattern1 = '/path/to/{stuff}/articles/article_{articleId}';
final pattern2 = '/path/to/{stuff}/article';
final pattern3 = '/articles/test';
final pattern4 = '/path/to/{stuff}/and/*';
final pattern5 = '/path/to/{stuff}/and/*/';
final invalid1 = '/invalid/path/{stuff}/and/*/no';
final invalid2 = '/*invalid/path/{stuff}/and/*/no';

final tests = [
  Triple(pattern1, '/path/to/some/articles/article_328',
      {'stuff': 'some', 'articleId': '328'}),
  Triple(pattern1, '/path/to/some/articles/article', null),
  Triple(pattern1, '/path/to/some/ArTiClEs/article_1',
      {'stuff': 'some', 'articleId': '1'}),
  Triple(pattern1, '/path/to/some/articles/article_', null),
  Triple(pattern1, '/path/to/some/ArTiClEs/article_', null),
  Triple(pattern1, '/path/to/articles/article_1', null),
  Triple(pattern1, '/path/to//articles/article_1', null),
  Triple(pattern2, '/path/to/some/article/article_328', null),
  Triple(pattern2, '/path/to/some/articles', null),
  Triple(pattern2, '/path/to/some/articles/', null),
  Triple(pattern2, '/path/to/some/articles/abc123', null),
  Triple(pattern2, '/path/to/some/articles/abc123/', null),
  Triple(pattern3, 'articles/test', null),
  Triple(pattern3, 'articles/test/', null),
  Triple(pattern3, '/articles/test', {}),
  Triple(pattern3, '/articles/test', {}),
  Triple(pattern3, '/articles/test/', {}),
  Triple(pattern4, '/path/to/some/articles', null),
  Triple(pattern4, '/path/to/some/and', {'stuff': 'some'}),
  Triple(pattern4, '/path/to/some/and/more/of/that', {'stuff': 'some'}),
  Triple(pattern4, '/path/to/some/other/stuff/', null),
  Triple(pattern5, '/path/to/some/articles', null),
  Triple(pattern5, '/path/to/some/and', {'stuff': 'some'}),
  Triple(pattern5, '/path/to/some/and/more/of/that', {'stuff': 'some'}),
  Triple(pattern5, '/path/to/some/other/stuff/', null),
];

final invalidRoutes = [invalid1, invalid2];

void _testRouteEncode() {
  final pattern1 = RoutePattern('/path/to/{stuff}/articles/article_{articleId}');
  final args1 = {'stuff': 'some', 'articleId': 328};
  final route1 = pattern1.encode(args1);
  expect(route1, equals('/path/to/some/articles/article_328'));
}

void _testRouteMatch() {
  for (final test in tests) {
    final pattern = RoutePattern(test.a);
    expect(pattern.match(test.b), test.c != null ? isTrue : isFalse,
        reason: 'Route:\n  ${test.b}\ndoes not match pattern:\n  ${test.a}');
  }
}

void _testRouteDecode() {
  for (final test in tests) {
    final pattern = RoutePattern(test.a);
    if (test.c == null) {
      expect(() => pattern.decode(test.b), throwsA(isA<ApiException>()));
    } else {
      try {
        final result = pattern.decode(test.b);
        expect(result.routeParams, equals(test.c));
      } catch (_) {
        fail('Could not decode:\n  ${test.b}\nfor pattern:\n  ${test.a}');
      }
    }
  }
}

void _testRouteInvalid() {
  for (final invalid in invalidRoutes) {
    expect(() => RoutePattern(invalid), throwsA(isA<ApiError>()));
  }
}

void _testIsWildcard() {
  final wildcardTests = [Tuple(pattern3, false), Tuple(pattern4, true)];
  for (final test in wildcardTests) {
    final pattern = RoutePattern(test.a);
    expect(pattern.isWildcardPattern, equals(test.b));
  }
}
