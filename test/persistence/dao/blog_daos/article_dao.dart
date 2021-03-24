import 'dart:typed_data';

import 'package:cl_datahub/cl_datahub.dart';

import 'blog_dao.dart';
import 'user_dao.dart';

@DaoType(name: 'article')
class ArticleDao {
  @PrimaryKeyDaoField()
  final int id;

  @ForeignKeyDaoField(UserDao)
  final int userId;

  @ForeignKeyDaoField(BlogDao)
  final String blogKey;

  final String title;
  final String content;
  final Uint8List image;

  final DateTime createdTimestamp;
  final DateTime lastEditTimestamp;

  ArticleDao(this.id, this.userId, this.blogKey, this.title, this.content,
      this.image, this.createdTimestamp, this.lastEditTimestamp);
}
