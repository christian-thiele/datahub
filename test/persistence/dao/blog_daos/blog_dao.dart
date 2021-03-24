import 'package:cl_datahub/cl_datahub.dart';

import 'user_dao.dart';

@DaoType(name: 'blog')
class BlogDao {
  @PrimaryKeyDaoField()
  final String key;

  @ForeignKeyDaoField(UserDao)
  final int ownerId;

  final String displayName;

  BlogDao(this.key, this.ownerId, this.displayName);
}
