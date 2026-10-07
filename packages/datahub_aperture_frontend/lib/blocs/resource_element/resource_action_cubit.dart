import 'package:datahub/api.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/error_state.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'resource_action_state.dart';

/// Runs an action (or sends a signal) with its parameters.
typedef ActionRunner = Future<void> Function(Map<String, dynamic> parameters);

/// Asks for the parameters of [action] and runs it with [run].
class ResourceActionCubit extends Cubit<ResourceActionState> {
  final ResourceAction action;
  final ActionRunner _run;

  /// [initialValues] fill in parameters, for example the element a signal is
  /// meant for.
  ResourceActionCubit({
    required this.action,
    required ActionRunner run,
    Map<String, dynamic> initialValues = const {},
  }) : _run = run,
       super(
         action.parameterFields.isEmpty
             ? const ResourceActionLoading()
             : ResourceActionEditing(
                 values: {
                   ..._initialValues(action.parameterFields),
                   ...initialValues,
                 },
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
          ResourceActionEditing(values: state.values, validation: validation),
        );
      }

      emit(const ResourceActionLoading());
      await _startAction(state.values);
    }
  }

  Future<void> _startAction(Map<String, dynamic> parameters) async {
    try {
      await _run(parameters);
      if (!isClosed) {
        emit(const ResourceActionDone());
      }
    } catch (e) {
      if (isClosed) {
        return;
      }

      // Parameters the backend rejected can be corrected in the form.
      if (editableFieldErrors(e, action.parameterFields) case final errors?) {
        emit(ResourceActionEditing(values: parameters, validation: errors));
      } else if (e case ApiRequestException(:final message)) {
        emit(ResourceActionError(message: message));
      } else {
        emit(const ResourceActionError());
      }
    }
  }
}
