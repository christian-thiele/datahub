import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

part 'todo.g.dart';

@Data()
@Meta(icon: Icons.checklist)
class const Todo({
  @Id(auto: true) final int id = 0,
  @MinLengthConstraint(length: 1)
  @MaxLengthConstraint(length: 255)
  @ApertureField(isDisplayField: true)
  required final String title,
  required final String description,
  required final DateTime? dueDate,
}) extends $Todo;
