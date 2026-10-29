import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

part 'note.g.dart';

@Data()
@Meta(icon: Icons.note)
class const Note({
  @Id(auto: true) final int id = 0,
  @ApertureField(isDisplayField: true) required final String title,
  required final String body,
  @ApertureField(allowSearch: false) required final String secret,
  required final int priority,
  required final DateTime created,
}) extends $Note;
