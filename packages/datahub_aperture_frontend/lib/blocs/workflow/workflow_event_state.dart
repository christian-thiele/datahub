part of 'workflow_event_cubit.dart';

sealed class WorkflowEventState {
  const WorkflowEventState();
}

final class WorkflowEventValue extends WorkflowEventState {
  final ResourceWorkflowEvent event;

  /// Whether the event is being retried or discarded.
  final bool busy;

  /// Why the event could not be retried or discarded.
  final String? error;

  const WorkflowEventValue({
    required this.event,
    this.busy = false,
    this.error,
  });
}

/// The event was handled or discarded.
final class WorkflowEventGone extends WorkflowEventState {
  final String eventId;

  const WorkflowEventGone({required this.eventId});
}
