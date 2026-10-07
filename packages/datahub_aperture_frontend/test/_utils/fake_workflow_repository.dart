import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/repositories/workflow_repository/workflow_repository.dart';

final _created = DateTime.utc(2026, 10, 1, 12);

/// A workflow event of the element '1'.
ResourceWorkflowEvent workflowEvent(
  String id, {
  String elementId = '1',
  String step = 'sent',
  WorkflowEventStatus status = WorkflowEventStatus.pending,
  bool running = false,
  DateTime? dueAt,
  int attempts = 0,
  String? lastError,
  Map<String, dynamic>? payload,
  List<String> messages = const [],
}) => ResourceWorkflowEvent(
  event: WorkflowEvent(
    id: id,
    workflow: 'Invoice',
    elementId: elementId,
    step: step,
    payload: payload,
    createdAt: _created,
    dueAt: dueAt ?? _created,
    status: status,
    attempts: attempts,
    lastError: lastError,
    startedAt: running ? _created : null,
    heartbeatAt: running ? _created : null,
    worker: running ? 'worker-1' : null,
    messages: messages,
  ),
  running: running,
);

WorkflowHistoryEntry historyEntry(
  String id,
  WorkflowHistoryKind kind, {
  String? step,
  String? state,
  String? newState,
}) => WorkflowHistoryEntry(
  id: id,
  workflow: 'Invoice',
  elementId: '1',
  timestamp: _created,
  kind: kind,
  step: step,
  state: state,
  newState: newState,
);

/// Serves [events] and [history] (newest first) and records the changes.
class FakeWorkflowRepository implements WorkflowRepository {
  List<ResourceWorkflowEvent> events;
  List<WorkflowHistoryEntry> history;

  /// Thrown when an event is retried or discarded.
  Object? error;

  int eventLoads = 0;
  int historyLoads = 0;
  final retried = <String>[];
  final cancelled = <String>[];
  final resumed = <String>[];
  final signals = <(String, String, Map<String, dynamic>)>[];

  FakeWorkflowRepository({this.events = const [], this.history = const []});

  @override
  Future<ResourceWorkflowEventsResponse> getEvents(
    String resourceId, {
    String? elementId,
    WorkflowEventStatus? status,
    int offset = 0,
    int limit = 50,
  }) async {
    eventLoads++;
    final matching = [
      for (final event in events)
        if ((elementId == null || event.event.elementId == elementId) &&
            (status == null || event.event.status == status))
          event,
    ];
    return ResourceWorkflowEventsResponse(
      hasNextPage: matching.length > offset + limit,
      data: matching.skip(offset).take(limit).toList(),
    );
  }

  @override
  Future<List<WorkflowHistoryEntry>> getHistory(
    String resourceId,
    String elementId, {
    int offset = 0,
    int limit = 25,
  }) async {
    historyLoads++;
    return history.skip(offset).take(limit).toList();
  }

  @override
  Future<void> sendSignal(
    String resourceId,
    String elementId,
    String signalId,
    Map<String, dynamic> payload,
  ) async => signals.add((elementId, signalId, payload));

  @override
  Future<void> retryEvent(String resourceId, String eventId) async {
    if (error case final error?) {
      throw error;
    }
    retried.add(eventId);
  }

  @override
  Future<void> cancelEvent(String resourceId, String eventId) async {
    if (error case final error?) {
      throw error;
    }
    cancelled.add(eventId);
    events = [
      for (final event in events)
        if (event.event.id != eventId) event,
    ];
  }

  @override
  Future<void> resume(String resourceId, String elementId) async =>
      resumed.add(elementId);
}
