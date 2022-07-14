import 'package:datahub/datahub.dart';

import 'user_dao.dart';

part 'blog_dao.g.dart';

@DaoType(name: 'blog')
class BlogDao extends _Dao {
  @PrimaryKeyDaoField()
  final String key;

  @ForeignKeyDaoField(UserDao)
  final int ownerId;

  final String displayName;

  BlogDao(this.key, this.ownerId, {required this.displayName});
}
