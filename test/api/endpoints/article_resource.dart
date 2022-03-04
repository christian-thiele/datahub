import 'dart:math';

import 'package:cl_datahub/cl_datahub.dart';

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
  ArticleResource() : super(RoutePattern('/articles/{id?}'), MapTransferBean());

  @override
  Future<Map<String, dynamic>> getElement(ApiRequest request, int id) async {
    if (id < articles.length) {
      return articles[id];
    } else {
      throw ApiRequestException.notFound();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getList(
      ApiRequest request, int offset, int limit) async {
    return articles.skip(offset).take(limit).toList(growable: false);
  }

  @override
  Future<int> getSize(ApiRequest request) async => articles.length;
}
