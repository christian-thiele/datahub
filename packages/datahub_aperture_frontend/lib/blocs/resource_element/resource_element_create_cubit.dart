import 'package:bloc/bloc.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';

part 'resource_element_create_state.dart';

class ResourceElementCreateCubit extends Cubit<ResourceElementCreateState> {
  final ResourcesRepository _resourceRepository;
  final String resourceId;

  ResourceElementCreateCubit(
    this._resourceRepository, {
    required this.resourceId,
  }) : super(ResourceElementCreateLoading()) {
    _init();
  }

  Future<void> _init() async {
    emit(ResourceElementCreateLoading());
    try {
      final resource = await _resourceRepository.getDescription(resourceId);
      final fields = resource.fields.where((f) => !f.readOnly).toList();
      final changes = <ResourceField, dynamic>{};
      for (final field in fields.where(
        (e) => e.type == ResourceFieldType.list,
      )) {
        changes[field] = [];
      }

      if (!isClosed) {
        emit(
          ResourceElementCreateEditing(
            fields: fields,
            changes: changes,
            validation: {},
            description: resource,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(ResourceElementCreateError(message: e.toString()));
      }
    }
  }

  void setFieldValue(String fieldId, dynamic value) {
    if (state case ResourceElementCreateValue(
      :final fields,
      :final changes,
      :final description,
    )) {
      final field = description.getField(fieldId);
      if (field.readOnly) {
        return;
      }

      final fieldValidation = validateFieldValue(field, value);
      final validation = <String, String>{
        if (state case ResourceElementCreateEditing(:final validation))
          ...validation,
      }..removeWhere((path, _) => isPathWithin(path, field.id));

      if (fieldValidation != null) {
        validation[field.id] = fieldValidation;
      }

      emit(
        ResourceElementCreateEditing(
          fields: fields,
          changes: {...changes, field: value},
          validation: validation,
          description: description,
        ),
      );
    }
  }

  Future<void> saveChanges({DateTime? from}) async {
    if (state case final ResourceElementCreateValue state
        when state is! ResourceElementCreateSaving) {
      try {
        final validation = <String, String>{
          for (final field in state.description.fields)
            field.id: ?validateFieldValue(field, state.changes[field]),
        };

        if (validation.isNotEmpty) {
          return emit(
            ResourceElementCreateEditing(
              fields: state.fields,
              changes: state.changes,
              validation: validation,
              description: state.description,
            ),
          );
        }

        final savingState = state.saving();
        emit(savingState);
        final updated = await _resourceRepository.createElement(
          resourceId,
          state.changes.map((key, value) => MapEntry(key.id, value)),
          from,
        );
        decodeFieldData(state.description, updated);

        emit(savingState.saved(updated.id, updated.version));
      } catch (e) {
        if (editableFieldErrors(e, state.description.fields)
            case final errors?) {
          emit(
            ResourceElementCreateEditing(
              description: state.description,
              fields: state.fields,
              changes: state.changes,
              validation: errors,
            ),
          );
        } else {
          emit(ResourceElementCreateError(message: e.toString()));
        }
      }
    }
  }
}
