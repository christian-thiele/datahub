import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

part 'todo.g.dart';

@Data()
@Meta(icon: Icons.checklist)
class Todo extends $Todo {
  @Id(auto: true)
  final int id;
  @MinLengthConstraint(length: 1)
  @MaxLengthConstraint(length: 255)
  @ApertureDisplayField()
  final String title;
  final String description;
  final DateTime? dueDate;

  const Todo({
    this.id = 0,
    required this.title,
    required this.description,
    required this.dueDate,
  });
}
