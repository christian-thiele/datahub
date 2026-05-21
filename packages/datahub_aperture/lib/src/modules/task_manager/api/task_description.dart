import 'package:datahub/datahub.dart';

part 'task_description.g.dart';

@Data()
class TaskDescription extends $TaskDescription {
  @Id()
  final String id;
  final String displayName;
  final int icon;

  const TaskDescription({
    required this.id,
    required this.displayName,
    required this.icon,
  });
}
