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
      PrimaryKey(type: StringDataType(), layoutName: 'blog', name: 'key'),
      ForeignKey(
          foreignPrimaryKey: PrimaryKey(
              type: SerialDataType(), layoutName: 'user', name: 'id'),
          layoutName: 'blog',
          name: 'ownerId'),
      DataField(type: StringDataType(), layoutName: 'blog', name: 'displayName')
    ]),
  );

  expect(ArticleDaoDataBean.layoutName, equals('article'));
  expect(
    ArticleDaoDataBean.fields,
    unorderedEquals([
      PrimaryKey(type: IntDataType(), layoutName: 'article', name: 'id'),
      ForeignKey(
          foreignPrimaryKey:
              PrimaryKey(type: IntDataType(), layoutName: 'user', name: 'id'),
          layoutName: 'article',
          name: 'userId'),
      ForeignKey(
          foreignPrimaryKey: PrimaryKey(
              type: StringDataType(), layoutName: 'blog', name: 'key'),
          layoutName: 'article',
          name: 'blogKey'),
      DataField(type: StringDataType(), layoutName: 'article', name: 'title'),
      DataField(type: StringDataType(), layoutName: 'article', name: 'content'),
      DataField(type: ByteDataType(), layoutName: 'article', name: 'image'),
      DataField(
          type: DateTimeDataType(),
          layoutName: 'article',
          name: 'createdTimestamp'),
      DataField(
          type: DateTimeDataType(),
          layoutName: 'article',
          name: 'lastEditTimestamp')
    ]),
  );

  expect(UserDaoDataBean.layoutName, equals('user'));
  expect(
    UserDaoDataBean.fields,
    unorderedEquals([
      PrimaryKey(type: IntDataType(), layoutName: 'user', name: 'id'),
      DataField(type: IntDataType(), layoutName: 'user', name: 'executionId'),
      DataField(
          type: StringDataType(length: 128),
          layoutName: 'user',
          name: 'username'),
      DataField(type: ByteDataType(), layoutName: 'user', name: 'image'),
    ]),
  );
}
