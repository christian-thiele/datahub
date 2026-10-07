import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/info_badge.dart';
import 'package:flutter/material.dart';

enum WorkflowEventDisplayStatus { pending, running, failed, expired }

extension WorkflowEventDisplay on ResourceWorkflowEvent {
  WorkflowEventDisplayStatus get displayStatus => switch (event.status) {
    WorkflowEventStatus.pending when running =>
      WorkflowEventDisplayStatus.running,
    WorkflowEventStatus.pending => WorkflowEventDisplayStatus.pending,
    WorkflowEventStatus.failed => WorkflowEventDisplayStatus.failed,
    WorkflowEventStatus.expired => WorkflowEventDisplayStatus.expired,
  };

  /// Whether the event is parked and can be set back to pending.
  bool get canRetry => event.status != WorkflowEventStatus.pending;

  /// Whether the event can be discarded: any event that is not running.
  bool get canDiscard => !running;

  /// Whether the event is a signal (and not entering a state).
  bool get isSignal => event.payload != null;

  IconData get icon => isSignal ? Icons.bolt : Icons.login;

  /// A short line about where the event stands.
  String describe(BuildContext context) {
    final s = S.of(context);
    return switch (displayStatus) {
      WorkflowEventDisplayStatus.running => s.eventRunningOn(
        event.worker ?? '?',
      ),
      WorkflowEventDisplayStatus.pending when event.attempts > 0 =>
        s.eventNextAttempt(event.dueAt.toLocal().formatDateTime()),
      WorkflowEventDisplayStatus.pending => s.eventDue(
        event.dueAt.toLocal().formatDateTime(),
      ),
      WorkflowEventDisplayStatus.failed => event.lastError ?? s.eventFailed,
      WorkflowEventDisplayStatus.expired => s.eventExpiredAt(
        (event.expiresAt ?? event.dueAt).toLocal().formatDateTime(),
      ),
    };
  }
}

class WorkflowEventBadge extends StatelessWidget {
  final ResourceWorkflowEvent event;

  const WorkflowEventBadge({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = ApertureColors.of(context);
    final (label, icon, color, background) = switch (event.displayStatus) {
      WorkflowEventDisplayStatus.pending => (
        s.eventPending,
        Icons.schedule,
        colors.link,
        colors.accentSubtle,
      ),
      WorkflowEventDisplayStatus.running => (
        s.eventRunning,
        Icons.sync,
        colors.success,
        colors.successSubtle,
      ),
      WorkflowEventDisplayStatus.failed => (
        s.eventFailed,
        Icons.error_outline,
        colors.danger,
        colors.dangerSubtle,
      ),
      WorkflowEventDisplayStatus.expired => (
        s.eventExpired,
        Icons.timer_off_outlined,
        colors.warning,
        colors.warningSubtle,
      ),
    };
    return StatusPill(
      label: label,
      icon: icon,
      color: color,
      background: background,
    );
  }
}
