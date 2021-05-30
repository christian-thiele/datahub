import 'dart:math';

import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/hub/api_resource.dart';

import '../../loremipsum.dart';

final articles = List.generate(
    50,
    (index) => {
          'title': 'Article about something!',
          'author': Random().nextInt(50),
          'published':
              DateTime.now().subtract(Duration(days: Random().nextInt(300))),
          'content': loremIpsum
        });

class ArticleResource extends ListApiResource<Map<String, dynamic>, int> {
  ArticleResource()
      : super(RoutePattern('/articles/{id?}'), (Map<String, dynamic> e) => e);

  @override
  Future<Map<String, dynamic>> getElement(int id) async {
    if (id < articles.length) {
      return articles[id];
    } else {
      throw ApiRequestException.notFound();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getList(int offset, int limit) async {
    return articles.skip(offset).take(limit).toList(growable: false);
  }

  @override
  Future getMetaData(String name) async {
    if (name == 'count') {
      return articles.length;
    }

    throw ApiRequestException.notFound();
  }
}
