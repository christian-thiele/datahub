import 'package:cl_datahub/cl_datahub.dart';
import 'package:test/test.dart';
import 'package:boost/boost.dart';

void main() {
  group('RoutePattern', () {
    test('pattern validity', _testRouteInvalid);
    test('isWildcardPattern', _testIsWildcard);
    test('containsParam', _testContainsParam);
    test('isOptionalParam', _testIsOptionalParam);
  });

  group('Route', () {
    test('Route encode', _testRouteEncode);
    test('Route match', _testRouteMatch);
    test('Route decode', _testRouteDecode);
  });
}

final pattern1 = '/path/to/{stuff}/articles/article_{articleId}';
final pattern2 = '/path/to/{stuff}/article';
final pattern3 = '/articles/test';
final pattern4 = '/path/to/{stuff}/and/*';
final pattern5 = '/path/to/{stuff}/and/*/';
final pattern6 = '/path/to/{stuff}/and/{optionalParam?}';
final pattern7 = '/path/to/{stuff}/and/{optionalParam?}/';
final pattern8 = 'path/to/{stuff}/and/{optionalParam?}/more';
final pattern9 = '/path/to/{stuff}/and/{optionalParam?}/*';
final patternX = '*';
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
  Triple(pattern3, '/articles/test/', {}),
  Triple(pattern4, '/path/to/some/articles', null),
  Triple(pattern4, '/path/to/some/and', {'stuff': 'some'}),
  Triple(pattern4, '/path/to/some/and/more/of/that', {'stuff': 'some'}),
  Triple(pattern4, '/path/to/some/other/stuff/', null),
  Triple(pattern5, '/path/to/some/articles', null),
  Triple(pattern5, '/path/to/some/and', {'stuff': 'some'}),
  Triple(pattern5, '/path/to/some/and/more/of/that', {'stuff': 'some'}),
  Triple(pattern5, '/path/to/some/other/stuff/', null),
  Triple(pattern6, '/path/to/required/and/optional',
      {'stuff': 'required', 'optionalParam': 'optional'}),
  Triple(pattern6, '/path/to/required/and/optional/',
      {'stuff': 'required', 'optionalParam': 'optional'}),
  Triple(pattern6, '/path/to/required/and', {'stuff': 'required'}),
  Triple(pattern6, '/path/to/required/and/', {'stuff': 'required'}),
  Triple(pattern6, '/path/to/required/and/optional/more', null),
  Triple(pattern6, '/path/to/required/and/optional/more/', null),
  Triple(pattern6, '/path/to/and/optional', null),
  Triple(pattern7, '/path/to/required/and/optional',
      {'stuff': 'required', 'optionalParam': 'optional'}),
  Triple(pattern7, '/path/to/required/and/optional/',
      {'stuff': 'required', 'optionalParam': 'optional'}),
  Triple(pattern7, '/path/to/required/and', {'stuff': 'required'}),
  Triple(pattern7, '/path/to/required/and/', {'stuff': 'required'}),
  Triple(pattern7, '/path/to/required/and/optional/more', null),
  Triple(pattern7, '/path/to/required/and/optional/more/', null),
  Triple(pattern7, '/path/to/and/optional', null),
  Triple(pattern8, '/path/to/required/and/optional', null),
  Triple(pattern8, '/path/to/required/and/optional/', null),
  Triple(pattern8, '/path/to/required/and', null),
  Triple(pattern8, '/path/to/required/and/', null),
  Triple(pattern8, '/path/to/required/and/optional/smth', null),
  Triple(pattern8, '/path/to/required/and/optional/smth/', null),
  Triple(pattern8, '/path/to/and/optional', null),
  Triple(pattern8, '/path/to/required/and/optional/more',
      {'stuff': 'required', 'optionalParam': 'optional'}),
  Triple(pattern9, '/path/to/required/and/optional/more',
      {'stuff': 'required', 'optionalParam': 'optional'}),
  Triple(pattern9, '/path/to/required/and/optional/more123/test',
      {'stuff': 'required', 'optionalParam': 'optional'}),
  Triple('/articles/{articleId?}', '/articles', {}),
  Triple('/articles/{articleId?}', '/articles/5', {'articleId': '5'}),
  Triple(
      '/articles/{articleId?}', '/articles/%24count', {'articleId': '\$count'}),
  Triple(
      '/profile/events/{id?}', '/profile/events/%24count', {'id': '\$count'}),
  Triple('/profile/events/{id?}', '/profile/events/\$count', {'id': '\$count'}),
  Triple(patternX, '/something/else', {}),
];

final invalidRoutes = [invalid1, invalid2];

void _testRouteEncode() {
  final p1 = RoutePattern('/path/to/{stuff}/articles/article_{articleId}');
  final args1 = {'stuff': 'some', 'articleId': 328};
  expect(p1.encode(args1), equals('/path/to/some/articles/article_328'));

  final p2 = RoutePattern('/path/to/{stuff}/articles/{articleId?}');
  final args21 = {'stuff': 'some', 'articleId': 328};
  final args22 = {'stuff': 'some'};
  expect(p2.encode(args21), equals('/path/to/some/articles/328'));
  expect(p2.encode(args22), equals('/path/to/some/articles'));

  final p3 = RoutePattern('/path/to/{stuff?}/articles/{articleId}');
  final args31 = {'stuff': 'some', 'articleId': 328};
  final args32 = {'articleId': 328};
  expect(p3.encode(args31), equals('/path/to/some/articles/328'));
  expect(p3.encode(args32), equals('/path/to/articles/328'));

  expect(() => p3.encode({}), throwsA(isA<ApiException>()));
}

void _testRouteMatch() {
  for (final test in tests) {
    final pattern = RoutePattern(test.a);
    expect(pattern.match(test.b), equals(test.c != null),
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
      } catch (e) {
        fail(
            'Could not decode:\n  ${test.b}\nfor pattern:\n  ${test.a}\n\nReason:\n${e.toString()}');
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
  final wildcardTests = [
    Tuple(pattern1, false),
    Tuple(pattern2, false),
    Tuple(pattern3, false),
    Tuple(pattern4, true),
    Tuple(pattern5, true),
    Tuple(pattern6, false),
    Tuple(pattern7, false),
    Tuple(pattern8, false),
    Tuple(pattern9, true)
  ];
  for (final test in wildcardTests) {
    final pattern = RoutePattern(test.a);
    expect(pattern.isWildcardPattern, equals(test.b), reason: test.a);
  }
}

void _testContainsParam() {
  for (final test in [pattern1, pattern2, pattern4, pattern5, pattern6]) {
    final pattern = RoutePattern(test);
    expect(pattern.containsParam('stuff'), isTrue);
  }

  final rp3 = RoutePattern(pattern3);
  expect(rp3.containsParam('stuff'), isFalse);

  for (final test in [pattern6, pattern7, pattern8, pattern9]) {
    final pattern = RoutePattern(test);
    expect(pattern.containsParam('optionalParam'), isTrue);
  }

  for (final test in [pattern1, pattern2, pattern4, pattern5]) {
    final pattern = RoutePattern(test);
    expect(pattern.containsParam('optionalParam'), isFalse);
  }
}

void _testIsOptionalParam() {
  for (final test in [pattern6, pattern7, pattern8, pattern9]) {
    final pattern = RoutePattern(test);
    expect(pattern.isOptionalParam('optionalParam'), isTrue);
    expect(pattern.isOptionalParam('stuff'), isFalse);
  }
}
