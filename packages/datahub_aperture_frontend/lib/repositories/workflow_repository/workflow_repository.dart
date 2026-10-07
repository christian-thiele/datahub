import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';

/// The workflows of resources, see `ResourceDescription.workflow`.
abstract interface class WorkflowRepository {
  /// The events of the workflow of [resourceId], optionally of one element and
  /// with one status, oldest first.
  Future<ResourceWorkflowEventsResponse> getEvents(
    String resourceId, {
    String? elementId,
    WorkflowEventStatus? status,
    int offset = 0,
    int limit = 50,
  });

  /// What happened to the element, newest first.
  Future<List<WorkflowHistoryEntry>> getHistory(
    String resourceId,
    String elementId, {
    int offset = 0,
    int limit = 25,
  });

  Future<void> sendSignal(
    String resourceId,
    String elementId,
    String signalId,
    Map<String, dynamic> payload,
  );

  /// Sets a parked event back to pending.
  Future<void> retryEvent(String resourceId, String eventId);

  /// Removes a pending or parked event.
  Future<void> cancelEvent(String resourceId, String eventId);

  /// Runs the steps of the current state of the element again.
  Future<void> resume(String resourceId, String elementId);
}
