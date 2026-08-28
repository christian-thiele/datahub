import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

void main() {
  test('plain path', () {
    expect(RoutePattern('/users/all').openApiPaths, equals(['/users/all']));
    expect(RoutePattern('/users/all').placeholders, isEmpty);
  });

  test('placeholder', () {
    final pattern = RoutePattern('/users/{name}/pictures');
    expect(pattern.openApiPaths, equals(['/users/{name}/pictures']));
    expect(
      pattern.placeholders,
      equals([(key: 'name', optional: false, prefix: '')]),
    );
  });

  test('optional placeholder', () {
    expect(
      RoutePattern('/articles/{id?}').openApiPaths,
      equals(['/articles', '/articles/{id}']),
    );
  });

  test('mid-pattern optional placeholder', () {
    expect(
      RoutePattern('/a/{x?}/b').openApiPaths,
      equals(['/a/b', '/a/{x}/b']),
    );
  });

  test('prefixed placeholder', () {
    final pattern = RoutePattern('/texts/article_{articleId}');
    expect(pattern.openApiPaths, equals(['/texts/article_{articleId}']));
    expect(
      pattern.placeholders,
      equals([(key: 'articleId', optional: false, prefix: 'article_')]),
    );
  });

  test('wildcard suffix', () {
    final pattern = RoutePattern('/files/{dir}/*');
    expect(pattern.openApiPaths, equals(['/files/{dir}']));
    expect(pattern.isWildcardPattern, isTrue);
  });

  test('any pattern', () {
    expect(RoutePattern.any.openApiPaths, equals(['/']));
  });
}
