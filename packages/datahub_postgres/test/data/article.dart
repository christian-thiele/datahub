import 'package:datahub/datahub.dart';

part 'article.g.dart';

@Data()
class Article extends $Article {
  @Id(auto: true)
  final String id;

  final int personId;

  final String title;
  final String content;

  const Article({
    required this.id,
    required this.personId,
    required this.title,
    required this.content,
  });
}
