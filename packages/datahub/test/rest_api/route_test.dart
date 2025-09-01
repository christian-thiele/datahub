import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

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
final pattern8 = '/path/to/{stuff}/and/{optionalParam?}/more';
final pattern9 = '/path/to/{stuff}/and/{optionalParam?}/*';
final pattern10 = '/path/to@special;{test}/char-.\$x';
final patternX = '/*';
final invalid1 = '/invalid/path/{stuff}/and/*/no';
final invalid2 = '/*invalid/path/{stuff}/and/*/no';

final tests = [
  (
    pattern1,
    '/path/to/some/articles/article_328',
    {'stuff': 'some', 'articleId': '328'}
  ),
  (pattern1, '/path/to/some/articles/article', null),
  (
    pattern1,
    '/path/to/some/ArTiClEs/article_1',
    {'stuff': 'some', 'articleId': '1'}
  ),
  (pattern1, '/path/to/some/articles/article_', null),
  (pattern1, '/path/to/some/ArTiClEs/article_', null),
  (pattern1, '/path/to/articles/article_1', null),
  (pattern1, '/path/to//articles/article_1', null),
  (pattern2, '/path/to/some/article/article_328', null),
  (pattern2, '/path/to/some/articles', null),
  (pattern2, '/path/to/some/articles/', null),
  (pattern2, '/path/to/some/articles/abc123', null),
  (pattern2, '/path/to/some/articles/abc123/', null),
  (pattern3, 'articles/test', null),
  (pattern3, 'articles/test/', null),
  (pattern3, '/articles/test', {}),
  (pattern3, '/articles/test/', {}),
  (pattern4, '/path/to/some/articles', null),
  (pattern4, '/path/to/some/and', {'stuff': 'some'}),
  (pattern4, '/path/to/some/and/more/of/that', {'stuff': 'some'}),
  (pattern4, '/path/to/some/other/stuff/', null),
  (pattern5, '/path/to/some/articles', null),
  (pattern5, '/path/to/some/and', {'stuff': 'some'}),
  (pattern5, '/path/to/some/and/more/of/that', {'stuff': 'some'}),
  (pattern5, '/path/to/some/other/stuff/', null),
  (
    pattern6,
    '/path/to/required/and/optional',
    {'stuff': 'required', 'optionalParam': 'optional'}
  ),
  (
    pattern6,
    '/path/to/required/and/optional/',
    {'stuff': 'required', 'optionalParam': 'optional'}
  ),
  (pattern6, '/path/to/required/and', {'stuff': 'required'}),
  (pattern6, '/path/to/required/and/', {'stuff': 'required'}),
  (pattern6, '/path/to/required/and/optional/more', null),
  (pattern6, '/path/to/required/and/optional/more/', null),
  (pattern6, '/path/to/and/optional', null),
  (
    pattern7,
    '/path/to/required/and/optional',
    {'stuff': 'required', 'optionalParam': 'optional'}
  ),
  (
    pattern7,
    '/path/to/required/and/optional/',
    {'stuff': 'required', 'optionalParam': 'optional'}
  ),
  (pattern7, '/path/to/required/and', {'stuff': 'required'}),
  (pattern7, '/path/to/required/and/', {'stuff': 'required'}),
  (pattern7, '/path/to/required/and/optional/more', null),
  (pattern7, '/path/to/required/and/optional/more/', null),
  (pattern7, '/path/to/and/optional', null),
  (pattern8, '/path/to/required/and/optional', null),
  (pattern8, '/path/to/required/and/optional/', null),
  (pattern8, '/path/to/required/and', null),
  (pattern8, '/path/to/required/and/', null),
  (pattern8, '/path/to/required/and/optional/smth', null),
  (pattern8, '/path/to/required/and/optional/smth/', null),
  (pattern8, '/path/to/and/optional', null),
  (
    pattern8,
    '/path/to/required/and/optional/more',
    {'stuff': 'required', 'optionalParam': 'optional'}
  ),
  (
    pattern9,
    '/path/to/required/and/optional/more',
    {'stuff': 'required', 'optionalParam': 'optional'}
  ),
  (
    pattern9,
    '/path/to/required/and/optional/more123/test',
    {'stuff': 'required', 'optionalParam': 'optional'}
  ),
  ('/articles/{articleId?}', '/articles', {}),
  ('/articles/{articleId?}', '/articles/5', {'articleId': '5'}),
  ('/articles/{articleId?}', '/articles/%24count', {'articleId': '\$count'}),
  ('/profile/events/{id?}', '/profile/events/%24count', {'id': '\$count'}),
  ('/profile/events/{id?}', '/profile/events/\$count', {'id': '\$count'}),
  (patternX, '/something/else', {}),
  (pattern10, '/path/to@special;abc/char-.\$x', {'test': 'abc'}),
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
    final pattern = RoutePattern(test.$1);
    expect(pattern.match(test.$2), equals(test.$3 != null),
        reason: 'Route:\n  ${test.$2}\ndoes not match pattern:\n  ${test.$1}');
  }
}

void _testRouteDecode() {
  for (final test in tests) {
    final pattern = RoutePattern(test.$1);
    if (test.$3 == null) {
      expect(() => pattern.decode(test.$2), throwsA(isA<ApiException>()));
    } else {
      try {
        final result = pattern.decode(test.$2);
        expect(result.routeParams, equals(test.$3));
      } catch (e) {
        fail(
            'Could not decode:\n  ${test.$2}\nfor pattern:\n  ${test.$1}\n\nReason:\n${e.toString()}');
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
    (pattern1, false),
    (pattern2, false),
    (pattern3, false),
    (pattern4, true),
    (pattern5, true),
    (pattern6, false),
    (pattern7, false),
    (pattern8, false),
    (pattern9, true),
    (patternX, true),
  ];
  for (final test in wildcardTests) {
    final pattern = RoutePattern(test.$1);
    expect(pattern.isWildcardPattern, equals(test.$2), reason: test.$1);
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
