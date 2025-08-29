import 'dart:typed_data';

import 'package:datahub/datahub.dart';

import 'blog_dao.dart';
import 'user_dao.dart';

part 'article_dao.g.dart';

@DaoType(name: 'article')
class ArticleDao extends _Dao {
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

  ArticleDao({
    this.id = 0,
    required this.userId,
    required this.blogKey,
    required this.title,
    required this.content,
    required this.image,
    required this.createdTimestamp,
    required this.lastEditTimestamp,
  });
}
