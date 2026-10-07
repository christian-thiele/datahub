import 'dart:convert';

import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/data/value_view.dart';
import 'package:datahub_aperture_frontend/widgets/dialogs/aperture_dialog.dart';
import 'package:flutter/material.dart';

import 'workflow_event_dialog.dart';

extension WorkflowHistoryDisplay on WorkflowHistoryEntry {
  String title(BuildContext context) {
    final s = S.of(context);
    final step = this.step ?? '';
    return switch (kind) {
      WorkflowHistoryKind.started => s.historyStarted(state ?? ''),
      WorkflowHistoryKind.resumed => s.historyResumed(state ?? ''),
      WorkflowHistoryKind.signalReceived => s.historySignalReceived(step),
      WorkflowHistoryKind.stepSucceeded => s.historyStepSucceeded(step),
      WorkflowHistoryKind.stepFailed => s.historyStepFailed(step),
      WorkflowHistoryKind.parked => s.historyParked(step),
      WorkflowHistoryKind.cancelled => s.historyCancelled(step),
      WorkflowHistoryKind.retried => s.historyRetried(step),
    };
  }

  IconData get icon => switch (kind) {
    WorkflowHistoryKind.started ||
    WorkflowHistoryKind.resumed => Icons.play_circle_outline,
    WorkflowHistoryKind.signalReceived => Icons.bolt,
    WorkflowHistoryKind.stepSucceeded => Icons.check_circle_outline,
    WorkflowHistoryKind.stepFailed => Icons.error_outline,
    WorkflowHistoryKind.parked => Icons.block,
    WorkflowHistoryKind.cancelled => Icons.cancel_outlined,
    WorkflowHistoryKind.retried => Icons.replay,
  };

  Color color(ApertureColors colors) => switch (kind) {
    WorkflowHistoryKind.stepSucceeded => colors.success,
    WorkflowHistoryKind.stepFailed => colors.warning,
    WorkflowHistoryKind.parked => colors.danger,
    WorkflowHistoryKind.cancelled => colors.textMuted,
    _ => colors.link,
  };

  /// The change of the state, if the entry moved the element.
  String? get transition => switch (newState) {
    final newState? when newState != state => '${state ?? '?'} → $newState',
    _ => null,
  };
}

/// An entry of the history of an element, in a list.
class WorkflowHistoryTile extends StatelessWidget {
  final WorkflowHistoryEntry entry;
  final VoidCallback onPressed;

  const WorkflowHistoryTile({
    super.key,
    required this.entry,
    required this.onPressed,
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
            Icon(entry.icon, size: 16, color: entry.color(colors)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title(context),
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    [
                      entry.timestamp.toLocal().formatDateTime(),
                      ?entry.transition,
                    ].join(' · '),
                    style: Theme.of(context).textTheme.labelMedium,
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

/// The details of an entry of the history of an element.
class WorkflowHistoryDialog extends StatelessWidget {
  final WorkflowHistoryEntry entry;

  /// The fields of the element, for the names of the changed fields.
  final List<ResourceField> fields;

  const WorkflowHistoryDialog({
    super.key,
    required this.entry,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = ApertureColors.of(context);
    String fieldName(String id) =>
        fields.where((field) => field.id == id).firstOrNull?.name ?? id;

    return ApertureDialog(
      title: entry.title(context),
      icon: entry.icon,
      iconColor: entry.color(colors),
      width: 600,
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.ok),
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            Wrap(
              spacing: 32,
              runSpacing: 12,
              children: [
                ValueView(
                  label: s.timestamp,
                  value: Text(entry.timestamp.toLocal().formatDateTime()),
                ),
                if (entry.state case final state?)
                  ValueView(
                    label: s.state,
                    value: Text(entry.transition ?? state),
                  ),
                if (entry.attempt case final attempt?)
                  ValueView(label: s.attempts, value: Text('$attempt')),
                if (entry.nextAttemptAt case final nextAttemptAt?)
                  ValueView(
                    label: s.nextAttempt,
                    value: Text(nextAttemptAt.toLocal().formatDateTime()),
                  ),
              ],
            ),
            if (entry.changes case final changes? when changes.isNotEmpty)
              WorkflowSection(
                title: s.changes,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    for (final MapEntry(:key, :value) in changes.entries)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${fieldName(key)}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: value is String ? value : jsonEncode(value),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            if (entry.error case final error?)
              WorkflowSection(
                title: s.error,
                child: SelectableText(
                  error,
                  style: TextStyle(color: colors.danger),
                ),
              ),
            if (entry.signal case final signal?)
              WorkflowSection(title: s.signal, child: JsonText(signal)),
            if (entry.messages.isNotEmpty)
              WorkflowSection(
                title: s.log,
                child: WorkflowLog(messages: entry.messages),
              ),
          ],
        ),
      ),
    );
  }
}
