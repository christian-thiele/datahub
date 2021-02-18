import 'dart:math';

import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/cl_datahub.dart';

import '../utils.dart';

final articles = List.generate(
    50,
    (index) => {
          'title': 'Article about something!',
          'author': Random().nextInt(50),
          'published':
              DateTime.now().subtract(Duration(days: Random().nextInt(300))),
          'content': loremIpsum
        });

/// Test endpoint extending ApiEndpoint
class ArticleEndpoint extends ApiEndpoint {
  ArticleEndpoint() : super(RoutePattern('/articles/{article?}'));

  @override
  Future get(ApiRequest request) async {
    if (request.route.routeParams.containsKey('article')) {
      final article = int.parse(request.route.routeParams['article']!);
      if (articles.length > article) {
        return articles[article];
      } else {
        throw ApiRequestException.notFound();
      }
    }

    return articles;
  }

  @override
  Future patch(ApiRequest request) async {
    final data = request.getJsonBody();
    print('patched.');
    return data;
  }

  @override
  Future post(ApiRequest request) async {
    print('posting');
    return request.getJsonBody();
  }
}
