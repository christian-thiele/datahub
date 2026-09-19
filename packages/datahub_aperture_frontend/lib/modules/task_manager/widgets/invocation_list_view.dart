import 'package:datahub/datahub.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/widgets/invocation_progress.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/page_header.dart';
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
        _SectionHeader(title: 'Active Tasks', count: active.length),
        for (final task in active) TaskSliver(task: task),
        _SectionHeader(title: 'History', count: history.length),
        for (final task in history) TaskSliver(task: task),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
        child: Row(
          spacing: 8,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: colors.textMuted),
              ),
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 14,
              children: [
                IconTile(Icons.bolt_outlined, size: 36),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          Flexible(
                            child: Text(
                              task.name,
                              style: Theme.of(context).textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            task.invocationId,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontFamily:
                                      GoogleFonts.jetBrainsMono().fontFamily,
                                ),
                          ),
                        ],
                      ),
                      DefaultTextStyle.merge(
                        style: Theme.of(context).textTheme.labelMedium,
                        child: InvocationProgress(task: task),
                      ),
                    ],
                  ),
                ),
                InvocationBadge(task: task),
                if (task.startedAt != null)
                  OutlinedButton.icon(
                    onPressed: () => context.go('./${task.invocationId}'),
                    icon: Icon(Icons.article_outlined),
                    label: Text('View Logs'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
