import 'package:datahub/datahub.dart';

import 'article_dao.dart';
import 'blog_dao.dart';
import 'user_dao.dart';

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
