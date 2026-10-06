import 'package:datahub/data.dart';

part 'workflow_event.g.dart';

enum WorkflowEventStatus {
  /// Waits to be handled, or to be retried after a failure.
  pending,

  /// All attempts to handle the event failed, or it can not be handled at all
  /// (for example because its step was removed from the workflow).
  failed,

  /// The signal was not applied before it expired.
  expired,
}

/// Something that is to happen to an element of a workflow: entering a state,
/// or a signal.
///
/// The workflow service removes an event once it was handled. Events that could
/// not be handled stay (with status [WorkflowEventStatus.failed] or
/// [WorkflowEventStatus.expired]) so that they can be inspected. Remove them,
/// or set them back to [WorkflowEventStatus.pending] to retry them.
@Data()
class WorkflowEvent extends $WorkflowEvent {
  @Id(auto: true)
  final String id;

  /// Name of the element type, which identifies the workflow.
  final String workflow;

  final String elementId;

  /// Name of the step that handles the event.
  final String step;

  /// The serialized signal, null for entering a state.
  final Map<String, dynamic>? payload;

  final DateTime createdAt;

  /// Earliest time the event is handled: after a delay of the step, or when
  /// the next attempt is due after a failure.
  final DateTime dueAt;

  /// Time after which a signal is not applied anymore.
  final DateTime? expiresAt;

  final WorkflowEventStatus status;

  /// Number of failed attempts to handle the event.
  final int attempts;

  final String? lastError;

  /// The trace (hex) of the code that created the event. The step that
  /// handles the event continues it, so it shows up in the trace of the request
  /// that sent the signal or moved the element.
  final String? traceId;

  /// The span (hex) of the code that created the event, see [traceId].
  final String? spanId;

  /// When the current attempt started, null while the event waits.
  ///
  /// An event is being handled when this is set and [heartbeatAt] is recent
  /// (it is renewed every `WorkflowService.heartbeatInterval`). If the worker
  /// crashed, the event is simply handled again by another worker.
  final DateTime? startedAt;

  /// Last sign of life of the worker handling the event.
  final DateTime? heartbeatAt;

  /// The worker handling the event (`WorkflowService.workerId`).
  final String? worker;

  /// What the step logged so far in the current attempt, one JSON object per
  /// line (see `LogMessage.toJsonLine`).
  final List<String> messages;

  const WorkflowEvent({
    this.id = '',
    required this.workflow,
    required this.elementId,
    required this.step,
    this.payload,
    required this.createdAt,
    required this.dueAt,
    this.expiresAt,
    this.status = WorkflowEventStatus.pending,
    this.attempts = 0,
    this.lastError,
    this.traceId,
    this.spanId,
    this.startedAt,
    this.heartbeatAt,
    this.worker,
    this.messages = const [],
  });
}
