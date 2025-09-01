import 'package:datahub/datahub.dart';

import 'slideshow.dart';

part 'example_object.g.dart';

@Data()
class ExampleObject extends _ExampleObject {
  final Slideshow slideshow;

  const ExampleObject({required this.slideshow});

  static DataBean<ExampleObject> get bean => _ExampleObject.bean;
}
