import 'package:datahub/data.dart';

/// What a workflow consists of, see `Workflow.describe`.
class const WorkflowDescription({
  /// Name of the element type, which identifies the workflow.
  required final String name,

  /// Name of the field of the element that holds its state.
  required final String stateField,
  required final List<WorkflowStepDescription> steps,

  /// The states the steps refer to. (The enum of the states is not available
  /// in general, so states without steps that are never referred to are
  /// missing.)
  required final List<String> states,

  /// Whether the history of the elements is written, see `Workflow.history`.
  required final bool writesHistory,
});

enum WorkflowStepKind() {
  /// An `OnEnter` step.
  enter,

  /// An `OnSignal` step.
  signal,
}

class const WorkflowStepDescription({
  required final String name,
  required final WorkflowStepKind kind,

  /// The state that triggers an `OnEnter` step.
  final String? state,

  /// The delay of an `OnEnter` step.
  final Duration? after,

  /// Whether an `OnEnter` step takes its time from the element (`at`).
  final bool scheduled = false,

  /// The states in which an `OnSignal` step accepts its signal.
  final List<String> accept = const [],

  /// The bean of the signal of an `OnSignal` step.
  final DataBean? signalBean,
  final String? failureState,
});
