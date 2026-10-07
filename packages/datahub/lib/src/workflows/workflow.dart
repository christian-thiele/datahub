import 'package:datahub/data.dart';

import 'workflow_description.dart';
import 'workflow_event.dart';
import 'workflow_history_entry.dart';
import 'workflow_signal.dart';
import 'workflow_step.dart';

/// The workflow of the element type [T].
///
/// Elements move through the workflow by events. Events are stored
/// and handled in the background, on any instance of the application.
///
/// See:
///   - [OnEnter]
///   - [OnSignal]
abstract interface class Workflow<T extends DataObject> {
  /// Stores [element] and starts its workflow in the state it has.
  ///
  /// Elements have to be started to move through the workflow. An element that
  /// is stored in any other way is ignored until it is [resume]d.
  Future<T> start(T element);

  /// Starts the workflow of an element that is already stored, in the state it
  /// has now: its [OnEnter] steps run as if it had just entered the state.
  ///
  /// Use it for elements that were stored without [start], whose state was
  /// changed outside of the workflow. Steps that already ran in this state
  /// will run again.
  ///
  /// Pending [OnEnter] steps of the element (of any state) are cancelled, so
  /// that steps of a state it left do not wait to be dropped and steps of its
  /// state do not run twice. Steps that are running right now are left alone.
  Future<void> resume(Object id);

  /// Sends [signal] and returns without waiting for it to be handled.
  ///
  /// Signals are fire-and-forget. The signal is stored and the workflow makes
  /// sure it is handled:
  ///
  /// - It waits until its element is in a state that accepts it and is not
  ///   busy.
  /// - A step that fails is retried with the retry rules of the step.
  /// - A signal that could not be applied before it expires, or whose attempts
  ///   all failed, is parked and logged as error.
  ///
  /// The sender does not have to retry or handle any of this. The call only
  /// throws if the signal could not be stored, in which case it was not sent
  /// and the sender **SHOULD** try again.
  ///
  /// If the workflow has no `OnSignal` step for the type of [signal], a warning
  /// is logged and the signal is dropped.
  Future<void> send(WorkflowSignal<T> signal);

  /// What happened to the element [id], oldest first (or [newestFirst]).
  ///
  /// The history is only written if a `DataRepository<WorkflowHistoryEntry>`
  /// is available (see [WorkflowDescription.writesHistory]), this throws
  /// otherwise.
  Future<List<WorkflowHistoryEntry>> history(
    Object id, {
    int offset = 0,
    int limit = 100,
    bool newestFirst = false,
  });

  /// The steps of the workflow.
  WorkflowDescription describe();

  /// The events of the workflow, optionally of one element and with one
  /// status, oldest first.
  ///
  /// Events that are being handled (see [isRunning]) show what the step
  /// logged so far in their `messages`.
  Future<List<WorkflowEvent>> events({
    Object? elementId,
    WorkflowEventStatus? status,
    int offset = 0,
    int limit = 100,
  });

  /// Whether a worker is handling [event] right now: it has `startedAt` set
  /// and a recent `heartbeatAt`.
  bool isRunning(WorkflowEvent event);

  /// Sets a parked (failed or expired) event back to pending, with a new round
  /// of attempts. A signal gets a new expiry.
  Future<void> retry(String eventId);

  /// Removes a pending or parked event, so it is not handled. Throws if the
  /// event is being handled right now.
  Future<void> cancel(String eventId);

  /// Sends the signal of type [signal] (the name of its bean) restored from
  /// [payload], see [send].
  ///
  /// Throws an `ApiRequestException` with status 400 if the payload is not a
  /// valid signal (naming the invalid fields in its `data`, like a
  /// `ValidationException`), or if [elementId] is given and the signal is
  /// meant for another element.
  Future<void> sendJson(
    String signal,
    Map<String, dynamic> payload, {
    Object? elementId,
  });
}
