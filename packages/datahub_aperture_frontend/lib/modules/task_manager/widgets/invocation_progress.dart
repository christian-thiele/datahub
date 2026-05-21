import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvocationProgress extends StatelessWidget {
  final TaskModel task;

  const InvocationProgress({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return switch (task) {
      TaskModel(:final startedAt?, :final finishedAt?) => Text(
        '${DateFormat.yMMMd().add_Hm().format(startedAt)} - ${formatCoarseDuration(finishedAt.difference(startedAt))}',
      ),
      TaskModel(:final finishedAt?) => Text(
        'Finished ${DateFormat.yMMMd().add_Hm().format(finishedAt)}',
      ),
      TaskModel(:final startedAt?) => Text(
        'Started ${formatAgoDuration(DateTime.timestamp().difference(startedAt))}',
      ),
      TaskModel(:final scheduledFor?) => Text(
        'Scheduled for: ${DateFormat.yMMMd().add_Hm().format(scheduledFor)}',
      ),
      _ => Text('Scheduled immediately'),
    };
  }
}
