import 'package:datahub/datahub.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/widgets/invocation_progress.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'invocation_badge.dart';

class InvocationTimeline extends StatelessWidget {
  final List<TaskModel> tasks;

  const InvocationTimeline({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final active = tasks.where(
      (e) => e.state == TaskState.scheduled || e.state == TaskState.running,
    );
    final history = tasks.where(
      (e) => e.state != TaskState.scheduled && e.state != TaskState.running,
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              'Active Tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),

        for (final task in active) TaskSliver(task: task),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              'History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),

        for (final task in history) TaskSliver(task: task),
      ],
    );
  }
}

class TaskSliver extends StatelessWidget {
  final TaskModel task;

  const TaskSliver({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card.outlined(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${task.invocationId}',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontFamily:
                                      GoogleFonts.jetBrainsMono().fontFamily,
                                ),
                          ),
                          Text(
                            task.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    InvocationBadge(task: task),
                  ],
                ),
                InvocationProgress(task: task),
                if (task.startedAt != null)
                  FilledButton(
                    onPressed: () => context.go('./${task.invocationId}'),
                    child: Text('View Logs'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
