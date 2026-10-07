import 'package:datahub/datahub.dart';

part 'resource_workflow_event.g.dart';

/// An event of the workflow of a resource.
@Data()
class ResourceWorkflowEvent extends $ResourceWorkflowEvent {
  final WorkflowEvent event;

  /// Whether a worker is handling the event right now.
  final bool running;

  const ResourceWorkflowEvent({required this.event, required this.running});
}

@Data()
class ResourceWorkflowEventsResponse extends $ResourceWorkflowEventsResponse {
  final bool hasNextPage;
  final List<ResourceWorkflowEvent> data;

  const ResourceWorkflowEventsResponse({
    required this.hasNextPage,
    required this.data,
  });
}
