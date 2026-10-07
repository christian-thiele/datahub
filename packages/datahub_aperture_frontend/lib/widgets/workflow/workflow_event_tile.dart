import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/material.dart';

import 'workflow_event_status.dart';

/// A workflow event in a list.
class WorkflowEventTile extends StatelessWidget {
  final ResourceWorkflowEvent event;
  final VoidCallback onPressed;

  /// Whether to show the element of the event (for lists of all elements).
  final bool showElement;

  const WorkflowEventTile({
    super.key,
    required this.event,
    required this.onPressed,
    this.showElement = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(ApertureThemeData.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          spacing: 10,
          children: [
            Icon(event.icon, size: 16, color: colors.textMuted),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showElement
                        ? '${event.event.step} · ${event.event.elementId}'
                        : event.event.step,
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    event.describe(context),
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            WorkflowEventBadge(event: event),
          ],
        ),
      ),
    );
  }
}
