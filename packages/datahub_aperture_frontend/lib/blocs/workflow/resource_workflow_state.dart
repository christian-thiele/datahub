part of 'resource_workflow_cubit.dart';

sealed class ResourceWorkflowState {
  const ResourceWorkflowState();
}

final class ResourceWorkflowLoading extends ResourceWorkflowState {
  const ResourceWorkflowLoading();
}

final class ResourceWorkflowValue extends ResourceWorkflowState {
  final ResourceDescription resource;

  /// The status of the events shown, null for all.
  final WorkflowEventStatus? status;
  final List<ResourceWorkflowEvent> events;
  final Paging paging;

  const ResourceWorkflowValue({
    required this.resource,
    required this.status,
    required this.events,
    required this.paging,
  });

  ResourceWorkflow get workflow => resource.workflow!;
}

final class ResourceWorkflowError extends ResourceWorkflowState
    implements ErrorState {
  @override
  final String? message;

  const ResourceWorkflowError({this.message});
}
