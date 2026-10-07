import 'dart:convert';

import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/workflow/workflow_event_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/repositories/workflow_repository/workflow_repository.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/data/value_view.dart';
import 'package:datahub_aperture_frontend/widgets/dialogs/aperture_dialog.dart';
import 'package:datahub_aperture_frontend/widgets/dialogs/confirmation_dialog.dart';
import 'package:datahub_aperture_frontend/widgets/log_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'workflow_event_status.dart';

/// The details of a workflow event, kept up to date while it is pending (so
/// the log of a running step grows), with Retry and Discard.
class WorkflowEventDialog extends StatelessWidget {
  final String resourceId;
  final ResourceWorkflowEvent event;

  /// Whether to offer opening the element of the event.
  final bool showElement;

  const WorkflowEventDialog({
    super.key,
    required this.resourceId,
    required this.event,
    this.showElement = false,
  });

  /// Shows the dialog and returns whether the event was retried or discarded.
  static Future<bool> show(
    BuildContext context, {
    required String resourceId,
    required ResourceWorkflowEvent event,
    bool showElement = false,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => WorkflowEventDialog(
          resourceId: resourceId,
          event: event,
          showElement: showElement,
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkflowEventCubit(
        context.read<WorkflowRepository>(),
        resourceId: resourceId,
        event: event,
      ),
      child: BlocConsumer<WorkflowEventCubit, WorkflowEventState>(
        // Discarding an event is all there is to do with it.
        listener: (context, state) {
          if (state is WorkflowEventGone &&
              context.read<WorkflowEventCubit>().changed) {
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          final cubit = context.read<WorkflowEventCubit>();
          void close() => Navigator.pop(context, cubit.changed);

          return switch (state) {
            WorkflowEventGone() => ApertureDialog(
              title: event.event.step,
              icon: event.icon,
              actions: [
                FilledButton(onPressed: close, child: Text(S.of(context).ok)),
              ],
              child: Text(S.of(context).eventHandled),
            ),
            WorkflowEventValue(:final event, :final busy, :final error) =>
              ApertureDialog(
                title: event.event.step,
                icon: event.icon,
                width: 600,
                actions: [
                  if (showElement)
                    TextButton(
                      onPressed: () {
                        final router = GoRouter.of(context);
                        close();
                        router.go(
                          '/resources/${Uri.encodeComponent(resourceId)}'
                          '/view/${Uri.encodeComponent(event.event.elementId)}',
                        );
                      },
                      child: Text(S.of(context).openElement),
                    ),
                  if (event.canDiscard)
                    OutlinedButton(
                      onPressed: busy
                          ? null
                          : () => ConfirmationDialog.show(
                              context,
                              title: S.of(context).caution,
                              child: Text(
                                S
                                    .of(context)
                                    .reallyDiscardEvent(event.event.step),
                              ),
                              confirmText: S.of(context).discard,
                              destructive: true,
                              onConfirmPressed: cubit.discard,
                            ),
                      child: Text(S.of(context).discard),
                    ),
                  if (event.canRetry)
                    OutlinedButton(
                      onPressed: busy ? null : cubit.retry,
                      child: Text(S.of(context).retry),
                    ),
                  FilledButton(onPressed: close, child: Text(S.of(context).ok)),
                ],
                child: _EventDetails(event: event, error: error),
              ),
          };
        },
      ),
    );
  }
}

class _EventDetails extends StatelessWidget {
  final ResourceWorkflowEvent event;

  /// Why the event could not be retried or discarded.
  final String? error;

  const _EventDetails({required this.event, this.error});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = ApertureColors.of(context);
    final e = event.event;
    String time(DateTime time) => time.toLocal().formatDateTime();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          Row(
            spacing: 12,
            children: [
              WorkflowEventBadge(event: event),
              Expanded(
                child: Text(
                  event.describe(context),
                  style: Theme.of(context).textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (error case final error?)
            Text(error, style: TextStyle(color: colors.danger)),
          Wrap(
            spacing: 32,
            runSpacing: 12,
            children: [
              ValueView(label: s.element, value: Text(e.elementId)),
              ValueView(label: s.created, value: Text(time(e.createdAt))),
              ValueView(label: s.due, value: Text(time(e.dueAt))),
              if (e.expiresAt case final expiresAt?)
                ValueView(label: s.expires, value: Text(time(expiresAt))),
              ValueView(label: s.attempts, value: Text('${e.attempts}')),
              if (e.startedAt case final startedAt?)
                ValueView(label: s.started, value: Text(time(startedAt))),
              if (e.heartbeatAt case final heartbeatAt?)
                ValueView(label: s.heartbeat, value: Text(time(heartbeatAt))),
              if (e.worker case final worker?)
                ValueView(label: s.worker, value: Text(worker)),
            ],
          ),
          if (e.lastError case final lastError?)
            WorkflowSection(
              title: s.error,
              child: SelectableText(
                lastError,
                style: TextStyle(color: colors.danger),
              ),
            ),
          if (e.payload case final payload?)
            WorkflowSection(title: s.signal, child: JsonText(payload)),
          WorkflowSection(
            title: s.log,
            child: WorkflowLog(messages: e.messages),
          ),
        ],
      ),
    );
  }
}

/// A titled part of the details of a workflow event or history entry.
class WorkflowSection extends StatelessWidget {
  final String title;
  final Widget child;

  const WorkflowSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelMedium),
        child,
      ],
    );
  }
}

/// The lines a step logged.
class WorkflowLog extends StatelessWidget {
  final List<String> messages;

  const WorkflowLog({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Text(
        S.of(context).noLog,
        style: TextStyle(color: ApertureColors.of(context).textMuted),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(ApertureThemeData.radiusSmall),
      ),
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (final line in messages) LogLine(line: line)],
        ),
      ),
    );
  }
}

/// JSON data, formatted.
class JsonText extends StatelessWidget {
  final Object? data;

  const JsonText(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(ApertureThemeData.radiusSmall),
      ),
      child: SelectableText(
        const JsonEncoder.withIndent('  ').convert(data),
        style: GoogleFonts.jetBrainsMono(fontSize: 12, height: 1.5),
      ),
    );
  }
}
