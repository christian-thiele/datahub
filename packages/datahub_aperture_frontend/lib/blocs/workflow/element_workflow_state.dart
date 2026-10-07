part of 'element_workflow_cubit.dart';

sealed class ElementWorkflowState {
  const ElementWorkflowState();
}

final class ElementWorkflowLoading extends ElementWorkflowState {
  const ElementWorkflowLoading();
}

final class ElementWorkflowValue extends ElementWorkflowState {
  /// The events of the element that are pending or parked.
  final List<ResourceWorkflowEvent> events;

  /// Newest first.
  final List<WorkflowHistoryEntry> history;
  final bool hasMoreHistory;

  const ElementWorkflowValue({
    required this.events,
    required this.history,
    required this.hasMoreHistory,
  });
}

final class ElementWorkflowError extends ElementWorkflowState
    implements ErrorState {
  @override
  final String? message;

  const ElementWorkflowError({this.message});
}
