import 'package:datahub/datahub.dart';

part 'slideshow.g.dart';

@TransferObject()
class Slideshow extends _TransferObject {
  final String author;
  final String date;
  final String title;

  Slideshow(this.author, this.date, this.title);

  @override
  bool operator ==(Object other) {
    return other is Slideshow &&
        author == other.author &&
        date == other.date &&
        title == other.title;
  }

  @override
  int get hashCode => Object.hashAll([author, date, title]);
}
