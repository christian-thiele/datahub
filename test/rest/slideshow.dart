import 'package:datahub/datahub.dart';

part 'slideshow.g.dart';

@TransferObject()
class Slideshow extends _TransferObject {
  final String author;
  final String date;
  final String title;

  Slideshow(this.author, this.date, this.title);
}
