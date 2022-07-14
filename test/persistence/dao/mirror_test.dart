import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

import 'blog_daos/article_dao.dart';
import 'blog_daos/blog_dao.dart';
import 'blog_daos/user_dao.dart';

void main() {
  test('example DAOs', _blogMirror);
}

void _blogMirror() {
  expect(BlogDaoDataBean.layoutName, equals('blog'));
  expect(
    BlogDaoDataBean.fields,
    unorderedEquals([
      PrimaryKey(FieldType.String, 'blog', 'key'),
      ForeignKey(PrimaryKey(FieldType.Int, 'user', 'id'), 'blog', 'ownerId'),
      DataField(FieldType.String, 'blog', 'displayName')
    ]),
  );

  expect(ArticleDaoDataBean.layoutName, equals('article'));
  expect(
    ArticleDaoDataBean.fields,
    unorderedEquals([
      PrimaryKey(FieldType.Int, 'article', 'id'),
      ForeignKey(PrimaryKey(FieldType.Int, 'user', 'id'), 'article', 'userId'),
      ForeignKey(
          PrimaryKey(FieldType.String, 'blog', 'key'), 'article', 'blogKey'),
      DataField(FieldType.String, 'article', 'title'),
      DataField(FieldType.String, 'article', 'content'),
      DataField(FieldType.Bytes, 'article', 'image'),
      DataField(FieldType.DateTime, 'article', 'createdTimestamp'),
      DataField(FieldType.DateTime, 'article', 'lastEditTimestamp')
    ]),
  );

  expect(UserDaoDataBean.layoutName, equals('user'));
  expect(
    UserDaoDataBean.fields,
    unorderedEquals([
      PrimaryKey(FieldType.Int, 'user', 'id'),
      DataField(FieldType.Int, 'user', 'executionId'),
      DataField(FieldType.String, 'user', 'username', length: 128),
      DataField(FieldType.Point, 'user', 'location', nullable: true),
      DataField(FieldType.Bytes, 'user', 'image'),
    ]),
  );
}
