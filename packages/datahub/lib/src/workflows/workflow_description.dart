import 'package:datahub/data.dart';

/// What a workflow consists of, see `Workflow.describe`.
class WorkflowDescription {
  /// Name of the element type, which identifies the workflow.
  final String name;

  final List<WorkflowStepDescription> steps;

  /// The states the steps refer to. (The enum of the states is not available
  /// in general, so states without steps that are never referred to are
  /// missing.)
  final List<String> states;

  const WorkflowDescription({
    required this.name,
    required this.steps,
    required this.states,
  });
}

enum WorkflowStepKind {
  /// An `OnEnter` step.
  enter,

  /// An `OnSignal` step.
  signal,
}

class WorkflowStepDescription {
  final String name;
  final WorkflowStepKind kind;

  /// The state that triggers an `OnEnter` step.
  final String? state;

  /// The delay of an `OnEnter` step.
  final Duration? after;

  /// Whether an `OnEnter` step takes its time from the element (`at`).
  final bool scheduled;

  /// The states in which an `OnSignal` step accepts its signal.
  final List<String> accept;

  /// The bean of the signal of an `OnSignal` step.
  final DataBean? signalBean;

  final String? failureState;

  const WorkflowStepDescription({
    required this.name,
    required this.kind,
    this.state,
    this.after,
    this.scheduled = false,
    this.accept = const [],
    this.signalBean,
    this.failureState,
  });
}
