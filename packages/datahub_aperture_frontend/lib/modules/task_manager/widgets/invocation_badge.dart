import 'package:datahub/tasks.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';
import 'package:datahub_aperture_frontend/widgets/info_badge.dart';
import 'package:flutter/material.dart';

class InvocationBadge extends StatelessWidget {
  final TaskModel task;

  const InvocationBadge({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return switch (task.state) {
      TaskState.scheduled => InfoBadge(
        icon: Icon(Icons.hourglass_empty),
        label: Text('PENDING'),
        minWidth: 96,
      ),
      TaskState.running => ProgressInfoBadge(
        label: Text('RUNNING'),
        minWidth: 96,
        progress: task.progress,
      ),
      TaskState.finished => InfoBadge(
        color: Colors.green,
        icon: Icon(Icons.check),
        label: Text('SUCCESS'),
        minWidth: 96,
      ),
      TaskState.failed => InfoBadge(
        color: Theme.of(context).colorScheme.error,
        icon: Icon(Icons.error_outline),
        label: Text('FAILED'),
        minWidth: 96,
      ),
      TaskState.timeout => InfoBadge(
        color: Theme.of(context).colorScheme.error,
        icon: Icon(Icons.error_outline),
        label: Text('TIMEOUT'),
        minWidth: 96,
      ),
      TaskState.canceled => InfoBadge(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        icon: Icon(Icons.error_outline),
        label: Text('FAILED'),
        minWidth: 96,
      ),
    };
  }
}
