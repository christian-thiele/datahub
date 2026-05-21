import 'package:datahub/datahub.dart';

part 'slideshow.g.dart';

@Data()
class Slideshow extends $Slideshow {
  final String author;
  final String date;
  final String title;

  const Slideshow({
    required this.author,
    required this.date,
    required this.title,
  });

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
