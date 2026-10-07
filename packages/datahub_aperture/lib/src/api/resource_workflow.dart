import 'package:datahub/datahub.dart';

import 'resource_action.dart';

part 'resource_workflow.g.dart';

/// The workflow the elements of a resource move through, see
/// `ResourceDescription.workflow`.
@Data()
class ResourceWorkflow extends $ResourceWorkflow {
  /// The field of the elements that holds their state.
  final String stateField;

  /// The states the steps refer to.
  final List<String> states;

  /// Whether the history of the elements is written.
  final bool writesHistory;

  final List<ResourceWorkflowStep> steps;

  /// The signals that can be sent to the elements.
  final List<ResourceWorkflowSignal> signals;

  const ResourceWorkflow({
    required this.stateField,
    required this.states,
    required this.writesHistory,
    required this.steps,
    required this.signals,
  });
}

@Data()
class ResourceWorkflowStep extends $ResourceWorkflowStep {
  final String name;
  final WorkflowStepKind kind;

  /// The state that triggers an enter step.
  final String? state;

  /// The delay of an enter step.
  final Duration? after;

  /// Whether an enter step takes its time from the element.
  final bool scheduled;

  /// The states in which a signal step accepts its signal.
  final List<String> accept;

  /// The signal of a signal step, the id of a [ResourceWorkflowSignal].
  final String? signal;

  /// The state an element is moved to when the step fails for good.
  final String? failureState;

  const ResourceWorkflowStep({
    required this.name,
    required this.kind,
    this.state,
    this.after,
    this.scheduled = false,
    this.accept = const [],
    this.signal,
    this.failureState,
  });
}

@Data()
class ResourceWorkflowSignal extends $ResourceWorkflowSignal {
  /// The signal as action: its id is the name of the signal, its parameters
  /// are the fields of the signal.
  ///
  /// The field holding the id of the element the signal is meant for has a
  /// lookup to the resource, if it is marked with `RelationId`.
  final ResourceAction action;

  /// The states in which the signal is accepted. A signal sent in any other
  /// state waits until the element reaches one of them.
  final List<String> accept;

  const ResourceWorkflowSignal({required this.action, required this.accept});
}
