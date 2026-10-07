import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';

/// Delay of reloads while events are being handled or due.
const workflowFastPoll = Duration(seconds: 2);

/// Longest delay of reloads while events are pending.
const workflowSlowPoll = Duration(seconds: 60);

/// When to reload workflow [events] to see them change: soon while one is
/// being handled or due, at the due time of the next one otherwise (at most
/// [workflowSlowPoll]), and never if none is pending.
Duration? workflowPollDelay(
  Iterable<ResourceWorkflowEvent> events,
  DateTime now,
) {
  final pending = events
      .where((e) => e.event.status == WorkflowEventStatus.pending)
      .toList();
  if (pending.isEmpty) {
    return null;
  }

  if (pending.any((e) => e.running || !e.event.dueAt.isAfter(now))) {
    return workflowFastPoll;
  }

  final next = pending
      .map((e) => e.event.dueAt)
      .reduce((a, b) => a.isBefore(b) ? a : b);
  final untilDue = next.difference(now);
  if (untilDue < workflowFastPoll) {
    return workflowFastPoll;
  }
  return untilDue > workflowSlowPoll ? workflowSlowPoll : untilDue;
}
