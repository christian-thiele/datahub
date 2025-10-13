import 'dart:async';

import 'package:datahub/api.dart';
import 'package:datahub_aperture/modules.dart';
import 'package:datahub_aperture_frontend/blocs/error_state.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/blocs/task_manager_module_cubit.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/repositories/task_manager_repository.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'resource_action_state.dart';

class ResourceActionCubit extends Cubit<ResourceActionState> {
  final ResourcesRepository _resourcesRepository;

  Timer? _progressUpdateTimer;

  ResourceActionCubit(
    this._resourcesRepository, {
    required String resourceId,
    required String actionId,
    required String elementId,
  }) : super(
         ResourceActionLoading(
           resourceId: resourceId,
           actionId: actionId,
           elementId: elementId,
         ),
       ) {
    _startAction();
  }

  Future<void> _startAction() async {
    try {
      // TODO fix this, this is messy
      /*
      final modules = await _resourcesRepository.getModules();
      final taskManagerEnabled = modules.any(
        (e) => e.type == ModuleType.taskManager,
      );*/
      final taskManagerEnabled = false;

      final result = await _resourcesRepository.startElementAction(
        state.resourceId,
        state.elementId,
        state.actionId,
      );
      /*
      if (taskManagerEnabled) {
        if (result['taskId'] case final taskId) {
          final descriptions = await _taskManagerRepository.getDescriptions();
          final invocation = await _taskManagerRepository.getInvocation(taskId);
          final taskDescription = descriptions
              .where((d) => d.id == invocation.taskId)
              .firstOrNull;
          emit(
            ResourceActionProgress(
              resourceId: state.resourceId,
              actionId: state.actionId,
              elementId: state.elementId,
              taskDescription: taskDescription,
              task: TaskManagerModuleCubit.toTaskModel(
                taskDescription,
                invocation,
              ),
            ),
          );
          _progressUpdateTimer = Timer(
            const Duration(seconds: 1),
            _progressUpdate,
          );
          return;
        }
      }*/
      emit(
        ResourceActionDone(
          resourceId: state.resourceId,
          actionId: state.actionId,
          elementId: state.elementId,
        ),
      );
    } catch (e) {
      if (e case ApiRequestException(:final message)) {
        emit(
          ResourceActionError(
            resourceId: state.resourceId,
            actionId: state.actionId,
            elementId: state.elementId,
            message: message,
          ),
        );
      } else {
        emit(
          ResourceActionError(
            resourceId: state.resourceId,
            actionId: state.actionId,
            elementId: state.elementId,
          ),
        );
      }
    }
  }

  void _progressUpdate() async {
    if (isClosed) {
      return;
    }
    /*
    if (state case ResourceActionProgress(
      :final taskDescription,
      :final task,
    )) {
      try {
        final invocation = await _taskManagerRepository.getInvocation(
          task.invocationId,
        );

        emit(
          ResourceActionProgress(
            resourceId: state.resourceId,
            actionId: state.actionId,
            elementId: state.elementId,
            taskDescription: taskDescription,
            task: TaskManagerModuleCubit.toTaskModel(
              taskDescription,
              invocation,
            ),
          ),
        );

        _progressUpdateTimer = Timer(
          const Duration(seconds: 1),
          _progressUpdate,
        );
      } catch (e) {
        emit(
          ResourceActionError(
            resourceId: state.resourceId,
            actionId: state.resourceId,
            elementId: state.elementId,
            message: 'Could not update task progress.',
          ),
        );
      }
    }*/
  }

  @override
  Future<void> close() {
    _progressUpdateTimer?.cancel();
    return super.close();
  }
}
