import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/modules.dart';
import 'package:datahub_aperture_frontend/blocs/error_state.dart';
import 'package:datahub_aperture_frontend/models/view_models/paging.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/repositories/task_manager_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'task_manager_module_state.dart';

class TaskManagerModuleCubit extends Cubit<TaskManagerModuleState> {
  final TaskManagerRepository _repository;
  Timer? _updateTimer;

  TaskManagerModuleCubit(this._repository)
    : super(const TaskManagerLoading.initial()) {
    update();
  }

  Paging get _paging => switch (state) {
    TaskManagerError() => Paging.empty(0, 25),
    TaskManagerLoading(:final paging) => paging,
    TaskManagerLoaded(:final paging) => paging,
  };

  void update() async {
    if (state case TaskManagerLoading(_initial: false)) {
      return;
    }

    emit(TaskManagerLoading(paging: _paging));
    _updateTimer?.cancel();
    try {
      final descriptions = await _repository.getDescriptions();
      final invocations = await _repository.getInvocations();
      emit(
        TaskManagerLoaded(
          paging: _paging,
          descriptions: descriptions,
          invocations: [
            for (final inv in invocations)
              toTaskModel(
                descriptions.where((e) => e.id == inv.taskId).firstOrNull,
                inv,
              ),
          ],
        ),
      );
      if (invocations.any(
        (inv) =>
            inv.state == TaskState.scheduled || inv.state == TaskState.running,
      )) {
        _updateTimer = Timer(Duration(seconds: 1), _autoUpdate);
      } else {
        _updateTimer = Timer(Duration(seconds: 10), _autoUpdate);
      }
    } catch (e) {
      if (e case ApiRequestException(:final message)) {
        emit(TaskManagerError(message: message));
      } else {
        emit(TaskManagerError());
      }
    }
  }

  Future<void> _autoUpdate() async {
    if (state case TaskManagerLoaded(:final descriptions)) {
      final previousState = state;
      try {
        final invocations = await _repository.getInvocations();
        if (previousState == state) {
          emit(
            TaskManagerLoaded(
              paging: _paging,
              descriptions: descriptions,
              invocations: [
                for (final inv in invocations)
                  toTaskModel(
                    descriptions.where((e) => e.id == inv.taskId).firstOrNull,
                    inv,
                  ),
              ],
            ),
          );
          if (invocations.any(
            (inv) =>
                inv.state == TaskState.scheduled ||
                inv.state == TaskState.running,
          )) {
            _updateTimer = Timer(Duration(seconds: 1), _autoUpdate);
          } else {
            _updateTimer = Timer(Duration(seconds: 10), _autoUpdate);
          }
        }
      } catch (e) {
        _updateTimer = Timer(Duration(minutes: 1), _autoUpdate);
      }
    }
  }

  @override
  Future<void> close() {
    _updateTimer?.cancel();
    return super.close();
  }

  static TaskModel toTaskModel(
    TaskDescription? description,
    TaskInvocation invocation,
  ) {
    return TaskModel(
      invocationId: invocation.id,
      name: description?.displayName ?? invocation.taskId,
      state: invocation.state,
      progress: invocation.progress,
      scheduledAt: invocation.scheduledAt,
      scheduledFor: invocation.scheduledAt != invocation.scheduledFor
          ? invocation.scheduledFor
          : null,
      startedAt: invocation.startedAt,
      finishedAt: invocation.finishedAt,
      messages: invocation.messages,
      parameters: invocation.parameters,
    );
  }
}
