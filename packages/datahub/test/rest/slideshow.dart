import 'package:datahub/datahub.dart';

part 'slideshow.g.dart';

@Data()
class Slideshow extends _Slideshow {
  final String author;
  final String date;
  final String title;

  const Slideshow({
    required this.author,
    required this.date,
    required this.title,
  });

  static get bean => _Slideshow.bean;

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
