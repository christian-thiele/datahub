import 'package:datahub/datahub.dart';

import 'slideshow.dart';

part 'example_object.g.dart';

@TransferObject()
class ExampleObject extends _TransferObject {
  final Slideshow slideshow;

  ExampleObject(this.slideshow);
}
