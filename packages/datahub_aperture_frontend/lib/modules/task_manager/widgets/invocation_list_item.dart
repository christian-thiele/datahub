import 'package:datahub/datahub.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'invocation_badge.dart';

class InvocationListItem extends StatelessWidget {
  final TaskModel task;

  const InvocationListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final meta = Theme.of(context).textTheme.labelMedium;
    String format(DateTime timestamp) =>
        DateFormat.yMMMd().add_Hm().format(timestamp);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          spacing: 12,
          children: [
            Expanded(
              child: Text(
                task.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            InvocationBadge(task: task),
            if (task.state == TaskState.scheduled)
              IconButton(onPressed: () {}, icon: Icon(Icons.cancel_outlined)),
          ],
        ),
        Text('Scheduled: ${format(task.scheduledAt)}', style: meta),
        if (task.scheduledFor case final timestamp?)
          Text('Scheduled for: ${format(timestamp)}', style: meta),
        if (task.startedAt case final timestamp?)
          Text('Started: ${format(timestamp)}', style: meta),
        if (task.finishedAt case final timestamp?)
          Text('Finished: ${format(timestamp)}', style: meta),
        for (final message in task.messages)
          Text(message, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
