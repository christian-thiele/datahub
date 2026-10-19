import 'package:datahub/datahub.dart';

import 'resource_action.dart';

part 'resource_workflow.g.dart';

/// The workflow the elements of a resource move through, see
/// `ResourceDescription.workflow`.
@Data()
class const ResourceWorkflow({
  /// The field of the elements that holds their state.
  required final String stateField,

  /// The states the steps refer to.
  required final List<String> states,

  /// Whether the history of the elements is written.
  required final bool writesHistory,
  required final List<ResourceWorkflowStep> steps,

  /// The signals that can be sent to the elements.
  required final List<ResourceWorkflowSignal> signals,
}) extends $ResourceWorkflow;

@Data()
class const ResourceWorkflowStep({
  required final String name,
  required final WorkflowStepKind kind,

  /// The state that triggers an enter step.
  final String? state,

  /// The delay of an enter step.
  final Duration? after,

  /// Whether an enter step takes its time from the element.
  final bool scheduled = false,

  /// The states in which a signal step accepts its signal.
  final List<String> accept = const [],

  /// The signal of a signal step, the id of a [ResourceWorkflowSignal].
  final String? signal,

  /// The state an element is moved to when the step fails for good.
  final String? failureState,
}) extends $ResourceWorkflowStep;

@Data()
class const ResourceWorkflowSignal({
  /// The signal as action: its id is the name of the signal, its parameters
  /// are the fields of the signal.
  ///
  /// The field holding the id of the element the signal is meant for has a
  /// lookup to the resource, if it is marked with `RelationId`.
  required final ResourceAction action,

  /// The states in which the signal is accepted. A signal sent in any other
  /// state waits until the element reaches one of them.
  required final List<String> accept,
}) extends $ResourceWorkflowSignal;
