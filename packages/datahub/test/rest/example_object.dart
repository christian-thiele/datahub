import 'package:datahub/datahub.dart';

import 'slideshow.dart';

part 'example_object.g.dart';

@Data()
class ExampleObject extends $ExampleObject {
  final Slideshow slideshow;

  const ExampleObject({required this.slideshow});
}
