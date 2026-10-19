import 'package:datahub/datahub.dart';

part 'slideshow.g.dart';

@Data()
class const Slideshow({
  required final String author,
  required final String date,
  required final String title,
}) extends $Slideshow {
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
