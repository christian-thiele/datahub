import 'package:cl_datahub/cl_datahub.dart';
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
        PrimaryKey(FieldType.String, 'key'),
        ForeignKey(PrimaryKey(FieldType.Int, 'id'), 'ownerId'),
        DataField(FieldType.String, 'displayName')
      ]));

  expect(ArticleDaoDataBean.layoutName, equals('article'));
  expect(
      ArticleDaoDataBean.fields,
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

  expect(UserDaoDataBean.layoutName, equals('user'));
  expect(
      UserDaoDataBean.fields,
      unorderedEquals([
        PrimaryKey(FieldType.Int, 'id'),
        DataField(FieldType.Int, 'executionId'),
        DataField(FieldType.String, 'username', length: 128),
        DataField(FieldType.Point, 'location', nullable: true),
        DataField(FieldType.Bytes, 'image'),
      ]));
}
