// ignore_for_file: unused_element, unused_local_variable

import 'dart:async';

import 'package:datahub/api.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/error_state.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'resource_action_state.dart';

class ResourceActionCubit extends Cubit<ResourceActionState> {
  final ResourcesRepository _resourcesRepository;
  final ResourceAction action;

  Timer? _progressUpdateTimer;

  ResourceActionCubit(
    this._resourcesRepository, {
    required String resourceId,
    required this.action,
    required String elementId,
  }) : super(
         action.parameterFields.isEmpty
             ? ResourceActionLoading(
                 resourceId: resourceId,
                 actionId: action.id,
                 elementId: elementId,
               )
             : ResourceActionEditing(
                 resourceId: resourceId,
                 actionId: action.id,
                 elementId: elementId,
                 values: _initialValues(action.parameterFields),
                 validation: const {},
               ),
       ) {
    if (state is ResourceActionLoading) {
      _startAction(const {});
    }
  }

  static Map<String, dynamic> _initialValues(List<ResourceField> fields) => {
    for (final field in fields)
      if (field.type == ResourceFieldType.list)
        field.id: []
      else if (field.type == ResourceFieldType.bool && !field.nullable)
        field.id: false,
  };

  void setParameterValue(ResourceField field, dynamic value) {
    if (state case final ResourceActionEditing state) {
      final validation = {...state.validation}
        ..removeWhere((path, _) => isPathWithin(path, field.id));
      if (validateFieldValue(field, value) case final error?) {
        validation[field.id] = error;
      }

      emit(
        ResourceActionEditing(
          resourceId: state.resourceId,
          actionId: state.actionId,
          elementId: state.elementId,
          values: {...state.values, field.id: value},
          validation: validation,
        ),
      );
    }
  }

  /// Starts the action with the parameters filled in, if they are valid.
  Future<void> start() async {
    if (state case final ResourceActionEditing state) {
      final validation = {
        for (final field in action.parameterFields)
          field.id: ?validateFieldValue(field, state.values[field.id]),
      };

      if (validation.isNotEmpty) {
        return emit(
          ResourceActionEditing(
            resourceId: state.resourceId,
            actionId: state.actionId,
            elementId: state.elementId,
            values: state.values,
            validation: validation,
          ),
        );
      }

      emit(
        ResourceActionLoading(
          resourceId: state.resourceId,
          actionId: state.actionId,
          elementId: state.elementId,
        ),
      );
      await _startAction(state.values);
    }
  }

  Future<void> _startAction(Map<String, dynamic> parameters) async {
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
        parameters,
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
      if (isClosed) {
        return;
      }

      // Parameters the backend rejected can be corrected in the form.
      if (editableFieldErrors(e, action.parameterFields) case final errors?) {
        emit(
          ResourceActionEditing(
            resourceId: state.resourceId,
            actionId: state.actionId,
            elementId: state.elementId,
            values: parameters,
            validation: errors,
          ),
        );
      } else if (e case ApiRequestException(:final message)) {
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
