import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:datahub/api.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/error_state.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/blocs/task_manager_module_cubit.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';

import '../repositories/task_manager_repository.dart';

part 'task_manager_log_state.dart';

class TaskManagerLogCubit extends Cubit<TaskManagerLogState> {
  final TaskManagerRepository _repository;
  final String invocationId;
  Timer? _updateTimer;
  TaskDescription? _description;

  TaskManagerLogCubit(this._repository, {required this.invocationId})
    : super(const TaskManagerLogLoading.initial()) {
    update();
  }

  void update() async {
    if (state case TaskManagerLogLoading(_initial: false)) {
      return;
    }

    emit(TaskManagerLogLoading());
    _updateTimer?.cancel();
    try {
      final descriptions = await _repository.getDescriptions();
      final invocation = await _repository.getInvocation(invocationId);
      _description = descriptions
          .where((e) => e.id == invocation.taskId)
          .firstOrNull;

      emit(
        TaskManagerLogLoaded(
          taskModel: TaskManagerModuleCubit.toTaskModel(
            _description,
            invocation,
          ),
        ),
      );

      if (invocation.finishedAt == null) {
        _updateTimer = Timer(Duration(seconds: 1), _autoUpdate);
      }
    } catch (e) {
      if (e case ApiRequestException(:final message)) {
        emit(TaskManagerLogError(message: message));
      } else {
        emit(TaskManagerLogError());
      }
    }
  }

  Future<void> _autoUpdate() async {
    if (state case TaskManagerLogLoaded()) {
      final previousState = state;
      try {
        final invocation = await _repository.getInvocation(invocationId);
        if (previousState == state) {
          emit(
            TaskManagerLogLoaded(
              taskModel: TaskManagerModuleCubit.toTaskModel(
                _description,
                invocation,
              ),
            ),
          );
          if (invocation.finishedAt == null) {
            _updateTimer = Timer(Duration(seconds: 1), _autoUpdate);
          }
        }
      } catch (e) {
        _updateTimer = Timer(Duration(minutes: 1), _autoUpdate);
      }
    }
  }
}
