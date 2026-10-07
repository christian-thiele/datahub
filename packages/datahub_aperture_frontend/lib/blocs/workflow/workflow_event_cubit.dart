import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/repositories/workflow_repository/workflow_repository.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:flutter/foundation.dart';

import 'workflow_polling.dart';

part 'workflow_event_state.dart';

/// One event of a workflow, kept up to date while it is pending (to show the
/// log of a running step), which can be retried or discarded.
class WorkflowEventCubit extends Cubit<WorkflowEventState> {
  final WorkflowRepository _repository;
  final String resourceId;

  final DateTime Function() _now;
  Timer? _poll;

  /// Whether the event was retried or discarded here.
  bool changed = false;

  WorkflowEventCubit(
    this._repository, {
    required this.resourceId,
    required ResourceWorkflowEvent event,
    @visibleForTesting DateTime Function()? now,
  }) : _now = now ?? DateTime.timestamp,
       super(WorkflowEventValue(event: event)) {
    _schedulePoll(event);
  }

  String get _eventId => switch (state) {
    WorkflowEventValue(:final event) => event.event.id,
    WorkflowEventGone(:final eventId) => eventId,
  };

  Future<void> reload() async {
    _poll?.cancel();
    if (state case WorkflowEventValue(:final event)) {
      try {
        final events = await _repository.getEvents(
          resourceId,
          elementId: event.event.elementId,
          limit: 100,
        );
        if (isClosed) {
          return;
        }

        final current = events.data
            .where((e) => e.event.id == event.event.id)
            .firstOrNull;
        if (current == null) {
          emit(WorkflowEventGone(eventId: event.event.id));
        } else {
          emit(WorkflowEventValue(event: current));
          _schedulePoll(current);
        }
      } catch (_) {
        // The event as it was is still shown.
        _schedulePoll(event);
      }
    }
  }

  void _schedulePoll(ResourceWorkflowEvent event) {
    if (isClosed) {
      return;
    }
    if (workflowPollDelay([event], _now()) case final delay?) {
      _poll = Timer(delay, reload);
    }
  }

  /// Sets the parked event back to pending.
  Future<void> retry() =>
      _change(() => _repository.retryEvent(resourceId, _eventId), gone: false);

  /// Removes the event, so that it is not handled.
  Future<void> discard() =>
      _change(() => _repository.cancelEvent(resourceId, _eventId), gone: true);

  Future<void> _change(
    Future<void> Function() change, {
    required bool gone,
  }) async {
    if (state case final WorkflowEventValue state when !state.busy) {
      emit(WorkflowEventValue(event: state.event, busy: true));
      try {
        await change();
        changed = true;
        if (gone) {
          emit(WorkflowEventGone(eventId: state.event.event.id));
        } else {
          emit(WorkflowEventValue(event: state.event));
          await reload();
        }
      } catch (e) {
        if (!isClosed) {
          emit(
            WorkflowEventValue(
              event: state.event,
              error: apiErrorMessage(e) ?? e.toString(),
            ),
          );
        }
      }
    }
  }

  @override
  Future<void> close() {
    _poll?.cancel();
    return super.close();
  }
}
