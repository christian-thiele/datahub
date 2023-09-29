import 'package:datahub/datahub.dart';

import 'blog_daos/article_dao.dart';
import 'blog_daos/blog_dao.dart';
import 'blog_daos/user_dao.dart';

class BlogSchema extends DataSchema {
  BlogSchema()
      : super(
          'blogsystem',
          1,
          [
            BlogDaoDataBean,
            ArticleDaoDataBean,
            UserDaoDataBean,
          ],
        );
}
