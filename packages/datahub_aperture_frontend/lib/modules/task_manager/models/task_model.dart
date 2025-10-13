import 'package:datahub/tasks.dart';

class TaskModel {
  final String invocationId;
  final String name;
  final TaskState state;
  final double progress;
  final DateTime scheduledAt;
  final DateTime? scheduledFor;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  TaskModel({
    required this.invocationId,
    required this.name,
    required this.state,
    required this.progress,
    required this.scheduledAt,
    required this.scheduledFor,
    required this.startedAt,
    required this.finishedAt,
  });
}
