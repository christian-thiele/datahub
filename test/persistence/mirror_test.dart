import 'dart:ffi';

import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

import 'lib/blogsystem/article_dao.dart';
import 'lib/blogsystem/blog_dao.dart';
import 'lib/blogsystem/user_dao.dart';

void main() {
  test('example DAOs', _blogMirror);
}

void _blogMirror() {
  expect(BlogDaoDataBean.layoutName, equals('blog'));
  expect(
    BlogDaoDataBean.fields,
    unorderedEquals([
      PrimaryKey<StringDataType>(layoutName: 'blog', name: 'key'),
      ForeignKey<IntDataType>(
        foreignPrimaryKey:
            PrimaryKey<IntDataType>(layoutName: 'user', name: 'id', length: 0),
        layoutName: 'blog',
        name: 'owner_id',
        nullable: false,
      ),
      DataField<StringDataType>(layoutName: 'blog', name: 'display_name'),
      DataField<BoolDataType>(layoutName: 'blog', name: 'enabled'),
    ]),
  );

  expect(ArticleDaoDataBean.layoutName, equals('article'));
  expect(
    ArticleDaoDataBean.fields,
    unorderedEquals([
      PrimaryKey<IntDataType>(layoutName: 'article', name: 'id'),
      ForeignKey<IntDataType>(
          foreignPrimaryKey:
              PrimaryKey<IntDataType>(layoutName: 'user', name: 'id'),
          layoutName: 'article',
          name: 'user_id'),
      ForeignKey(
        foreignPrimaryKey:
            PrimaryKey<StringDataType>(layoutName: 'blog', name: 'key'),
        layoutName: 'article',
        name: 'blog_key',
      ),
      DataField<StringDataType>(layoutName: 'article', name: 'title'),
      DataField<StringDataType>(layoutName: 'article', name: 'content'),
      DataField<ByteDataType>(layoutName: 'article', name: 'image'),
      DataField<DateTimeDataType>(
          layoutName: 'article', name: 'created_timestamp'),
      DataField<DateTimeDataType>(
          layoutName: 'article', name: 'last_edit_timestamp')
    ]),
  );

  expect(UserDaoDataBean.layoutName, equals('user'));
  expect(
    UserDaoDataBean.fields,
    unorderedEquals([
      PrimaryKey<IntDataType>(layoutName: 'user', name: 'id'),
      DataField<IntDataType>(layoutName: 'user', name: 'execution_id'),
      DataField<StringDataType>(
          length: 128, layoutName: 'user', name: 'username'),
      DataField<ByteDataType>(layoutName: 'user', name: 'image'),
    ]),
  );
}
