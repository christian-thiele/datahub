import 'package:cl_datahub/cl_datahub.dart';
import 'package:test/test.dart';

import 'blog_daos/article_dao.dart';
import 'blog_daos/blog_dao.dart';
import 'blog_daos/user_dao.dart';

import 'misc/invalid_dao.dart';
import '../../utils/message_matcher.dart';

void main() {
  test('Mirror Blog example DAOs', _blogMirror);
  test('Invalid dao handling', _invalidMirror);
}

void _blogMirror() {
  final blogLayout = LayoutMirror.reflect(BlogDao);
  expect(blogLayout.name, equals('blog'));
  expect(
      blogLayout.fields,
      unorderedEquals([
        PrimaryKey(FieldType.String, 'key'),
        ForeignKey(PrimaryKey(FieldType.Int, 'id'), 'ownerId'),
        DataField(FieldType.String, 'displayName')
      ]));

  final articleLayout = LayoutMirror.reflect(ArticleDao);
  expect(articleLayout.name, equals('article'));
  expect(
      articleLayout.fields,
      unorderedEquals([
        PrimaryKey(FieldType.Int, 'id'),
        ForeignKey(PrimaryKey(FieldType.Int, 'id'), 'userId'),
        ForeignKey(PrimaryKey(FieldType.String, 'key'), 'blogKey'),
        DataField(FieldType.String, 'title'),
        DataField(FieldType.String, 'content'),
        DataField(FieldType.Bytes, 'image'),
        DataField(FieldType.DateTime, 'createdTimestamp'),
        DataField(FieldType.DateTime, 'lastEditTimestamp')
      ]));

  final userLayout = LayoutMirror.reflect(UserDao);
  expect(userLayout.name, equals('user'));
  expect(
      userLayout.fields,
      unorderedEquals([
        PrimaryKey(FieldType.Int, 'id'),
        DataField(FieldType.Int, 'executionId'),
        DataField(FieldType.String, 'name'),
        DataField(FieldType.Point, 'location'),
        DataField(FieldType.Bytes, 'image'),
      ]));
}

void _invalidMirror() {
  expect(
      () => LayoutMirror.reflect(InvalidPrimaryDao),
      throwsWithType<MirrorException>(
          'Invalid field type for primary key field: FieldType.DateTime'));

  expect(() => LayoutMirror.reflect(MultiplePrimaryDao),
      throwsWithType<MirrorException>('DAO has multiple primary key fields.'));

  expect(
      () => LayoutMirror.reflect(InvalidForeignDao),
      throwsWithType<MirrorException>(
          'Foreign key field "invalidForeign" does not match type of foreign primary key.'));

  expect(() => LayoutMirror.reflect(InvalidTypeDao),
      throwsWithType<MirrorException>('Invalid field type: Future<dynamic>'));
}
