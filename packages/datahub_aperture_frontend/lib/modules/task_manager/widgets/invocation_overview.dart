import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/page_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'duration_card.dart';
import 'log_line.dart';

class InvocationOverview extends StatelessWidget {
  final TaskModel task;

  const InvocationOverview({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final mono = GoogleFonts.jetBrainsMono().fontFamily;
    final colors = ApertureColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.event_outlined,
                label: 'Scheduled',
                value: task.scheduledAt.formatDateTime(),
              ),
            ),
            Expanded(
              child: StatCard(
                icon: Icons.play_arrow_outlined,
                label: 'Started',
                value: task.startedAt?.formatDateTime() ?? '-',
              ),
            ),
            Expanded(child: DurationCard(task: task)),
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 6,
                children: [
                  for (final (key, value) in [
                    ('invocationId', task.invocationId),
                    for (final property in task.parameters.entries)
                      (property.key, property.value.toString()),
                  ])
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$key: ',
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium?.copyWith(fontFamily: mono),
                          ),
                          TextSpan(
                            text: value,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontFamily: mono),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    spacing: 8,
                    children: [
                      Icon(Icons.terminal, size: 16, color: colors.textMuted),
                      Text(
                        'Log',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '${task.messages.length}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: SelectionArea(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      itemBuilder: (context, index) =>
                          LogLine(line: task.messages[index]),
                      itemCount: task.messages.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A card with a small label above a value.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          spacing: 12,
          children: [
            IconTile(icon, size: 36),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
