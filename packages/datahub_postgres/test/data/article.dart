import 'package:datahub/datahub.dart';

part 'article.g.dart';

@Data()
class const Article({
  @Id(auto: true) required final String id,
  required final int personId,
  required final String title,
  required final String content,
}) extends $Article;
