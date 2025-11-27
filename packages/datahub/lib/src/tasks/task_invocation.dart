import 'package:datahub/data.dart';

part 'task_invocation.g.dart';

enum TaskState { scheduled, running, finished, failed, timeout, canceled }

@Data()
class TaskInvocation extends $TaskInvocation {
  @Id(auto: true)
  final String id;
  final String taskId;
  final TaskState state;
  final Map<String, dynamic> parameters;
  final DateTime scheduledAt;
  final DateTime scheduledFor;
  final DateTime? startedAt;
  final DateTime? lastHeartbeat;
  final double progress;
  final List<String> messages;
  final DateTime? finishedAt;

  const TaskInvocation({
    this.id = '',
    required this.taskId,
    required this.state,
    required this.parameters,
    required this.scheduledAt,
    required this.scheduledFor,
    required this.lastHeartbeat,
    required this.progress,
    required this.startedAt,
    required this.messages,
    required this.finishedAt,
  });
}
