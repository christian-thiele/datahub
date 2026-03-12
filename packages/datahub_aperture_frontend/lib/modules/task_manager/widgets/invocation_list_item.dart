import 'package:datahub/datahub.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';
import 'package:datahub_aperture_frontend/widgets/info_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvocationListItem extends StatelessWidget {
  final TaskModel task;

  const InvocationListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          spacing: 16,
          children: [
            switch (task.state) {
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
            },
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.name),
                  Text(
                    'Scheduled: ${DateFormat.yMMMd().add_Hm().format(task.scheduledAt)}',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.scheduledFor case final timestamp?)
                    Text(
                      'Scheduled for: ${DateFormat.yMMMd().add_Hm().format(timestamp)}',
                    ),
                  if (task.startedAt case final timestamp?)
                    Text(
                      'Started: ${DateFormat.yMMMd().add_Hm().format(timestamp)}',
                    ),
                  if (task.finishedAt case final timestamp?)
                    Text(
                      'Finished: ${DateFormat.yMMMd().add_Hm().format(timestamp)}',
                    ),
                ],
              ),
            ),
            if (task.state == TaskState.scheduled)
              IconButton(onPressed: () {}, icon: Icon(Icons.cancel_outlined)),
          ],
        ),
        for (final message in task.messages)
          Text(message),
      ],
    );
  }
}
