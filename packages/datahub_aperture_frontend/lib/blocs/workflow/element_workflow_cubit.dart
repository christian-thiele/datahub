import 'dart:async';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/error_state.dart';
import 'package:datahub_aperture_frontend/repositories/workflow_repository/workflow_repository.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:flutter/foundation.dart';

import 'workflow_polling.dart';

part 'element_workflow_state.dart';

/// The workflow of one element: its open events and its history, newest
/// first.
///
/// While events are pending, it reloads by itself (see [workflowPollDelay]).
class ElementWorkflowCubit extends Cubit<ElementWorkflowState> {
  static const historyPageSize = 25;

  final WorkflowRepository _repository;
  final String resourceId;
  final String elementId;

  /// Whether the history is written, see `ResourceWorkflow.writesHistory`.
  final bool writesHistory;

  /// Called when the workflow may have changed the element: an event is gone
  /// or there is a new history entry.
  final VoidCallback? onElementChanged;

  final DateTime Function() _now;
  Timer? _poll;
  Future<void> _loading = Future.value();

  ElementWorkflowCubit(
    this._repository, {
    required this.resourceId,
    required this.elementId,
    required this.writesHistory,
    this.onElementChanged,
    @visibleForTesting DateTime Function()? now,
  }) : _now = now ?? DateTime.timestamp,
       super(const ElementWorkflowLoading()) {
    reload();
  }

  /// Loads the events and the history again. Loads are done one after the
  /// other.
  Future<void> reload() => _loading = _loading.then((_) => _load());

  Future<void> _load() async {
    if (isClosed) {
      return;
    }
    _poll?.cancel();

    final previous = state;
    // Keeps the history entries that were loaded so far.
    final historyLimit = switch (previous) {
      ElementWorkflowValue(:final history) => math.min(
        100,
        math.max(historyPageSize, history.length),
      ),
      _ => historyPageSize,
    };

    try {
      final events = await _repository.getEvents(
        resourceId,
        elementId: elementId,
        limit: 100,
      );
      final history = writesHistory
          ? await _repository.getHistory(
              resourceId,
              elementId,
              limit: historyLimit,
            )
          : const <WorkflowHistoryEntry>[];
      if (isClosed) {
        return;
      }

      final value = ElementWorkflowValue(
        events: events.data,
        history: history,
        hasMoreHistory: history.length == historyLimit,
      );
      emit(value);
      if (previous case final ElementWorkflowValue previous
          when _elementChanged(previous, value)) {
        onElementChanged?.call();
      }
    } catch (e) {
      if (isClosed) {
        return;
      }
      // What was loaded before is still shown, the next load may work.
      if (previous is! ElementWorkflowValue) {
        emit(ElementWorkflowError(message: apiErrorMessage(e)));
      }
    }

    _schedulePoll();
  }

  void _schedulePoll() {
    if (isClosed) {
      return;
    }
    if (state case ElementWorkflowValue(:final events)) {
      if (workflowPollDelay(events, _now()) case final delay?) {
        _poll = Timer(delay, reload);
      }
    }
  }

  static bool _elementChanged(
    ElementWorkflowValue before,
    ElementWorkflowValue after,
  ) {
    final open = {for (final event in after.events) event.event.id};
    return before.events.any((event) => !open.contains(event.event.id)) ||
        after.history.firstOrNull?.id != before.history.firstOrNull?.id;
  }

  Future<void> loadMoreHistory() async {
    if (state case ElementWorkflowValue(:final history, hasMoreHistory: true)) {
      final page = await _repository.getHistory(
        resourceId,
        elementId,
        offset: history.length,
        limit: historyPageSize,
      );
      if (isClosed) {
        return;
      }
      // Reloads in the meantime may have loaded some of them already.
      if (state case final ElementWorkflowValue current) {
        final known = {for (final entry in current.history) entry.id};
        emit(
          ElementWorkflowValue(
            events: current.events,
            history: [
              ...current.history,
              ...page.where((entry) => !known.contains(entry.id)),
            ],
            hasMoreHistory: page.length == historyPageSize,
          ),
        );
      }
    }
  }

  /// Runs the steps of the current state of the element again.
  Future<void> resume() async {
    await _repository.resume(resourceId, elementId);
    await reload();
  }

  @override
  Future<void> close() {
    _poll?.cancel();
    return super.close();
  }
}
