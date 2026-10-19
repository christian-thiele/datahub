import 'package:datahub/datahub.dart';

part 'resource_workflow_event.g.dart';

/// An event of the workflow of a resource.
@Data()
class const ResourceWorkflowEvent({
  required final WorkflowEvent event,

  /// Whether a worker is handling the event right now.
  required final bool running,
}) extends $ResourceWorkflowEvent;

@Data()
class const ResourceWorkflowEventsResponse({
  required final bool hasNextPage,
  required final List<ResourceWorkflowEvent> data,
}) extends $ResourceWorkflowEventsResponse;
