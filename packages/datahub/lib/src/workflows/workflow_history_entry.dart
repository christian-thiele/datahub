import 'package:datahub/data.dart';

part 'workflow_history_entry.g.dart';

enum WorkflowHistoryKind {
  /// The element was started with `Workflow.start`.
  started,

  /// The element was resumed with `Workflow.resume`.
  resumed,

  /// A signal was sent for the element.
  signalReceived,

  /// A step ran and its result was written.
  stepSucceeded,

  /// An attempt of a step failed.
  stepFailed,

  /// An event was given up: its attempts all failed and there is no failure
  /// state, the signal expired, or its step does not exist anymore.
  parked,

  /// A pending step was cancelled because the element left its state.
  cancelled,
}

/// Something that happened to an element of a workflow.
///
/// The workflow service writes the history if a
/// `DataRepository<WorkflowHistoryEntry>` is available, and never changes or
/// removes entries. Read it with `Workflow.history`.
///
/// Entries are written after the fact and independently of the element. If
/// the process crashes in between, an entry can be missing, and a step that
/// runs again after a crash shows up again.
@Data()
class WorkflowHistoryEntry extends $WorkflowHistoryEntry {
  @Id(auto: true)
  final String id;

  /// Name of the element type, which identifies the workflow.
  final String workflow;

  final String elementId;

  final DateTime timestamp;

  final WorkflowHistoryKind kind;

  /// The step the entry is about.
  final String? step;

  /// The event the entry is about. It links the entries of a signal or a
  /// delayed step to the attempts that handled it.
  final String? eventId;

  final int? attempt;

  /// The state of the element when it happened.
  final String? state;

  /// The state the element was moved to, by a step or to the failure state.
  final String? newState;

  /// The fields a step changed, by name, with their new values.
  final Map<String, dynamic>? changes;

  /// The signal, for [WorkflowHistoryKind.signalReceived].
  final Map<String, dynamic>? signal;

  final String? error;

  /// When the next attempt is due, for a failed attempt that is retried.
  final DateTime? nextAttemptAt;

  /// What the step logged while it ran, one JSON object per line (the format
  /// of `TaskInvocation.messages`).
  final List<String> messages;

  const WorkflowHistoryEntry({
    this.id = '',
    required this.workflow,
    required this.elementId,
    required this.timestamp,
    required this.kind,
    this.step,
    this.eventId,
    this.attempt,
    this.state,
    this.newState,
    this.changes,
    this.signal,
    this.error,
    this.nextAttemptAt,
    this.messages = const [],
  });
}
