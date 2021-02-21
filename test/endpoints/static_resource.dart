import 'package:cl_datahub/src/api/hub/static_api_resource.dart';

final articles = List.generate(
    50,
        (index) => {
      'title': 'Article about something!',
      'author': Random().nextInt(50),
      'published':
      DateTime.now().subtract(Duration(days: Random().nextInt(300))),
      'content': loremIpsum
    });

class TestStaticResource extends StaticApiResource<>