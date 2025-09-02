import 'package:datahub_aperture_frontend/models/authentication.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'resource_element_create_state.dart';

class ResourceElementCreateCubit extends Cubit<ResourceElementCreateState> {
  final ResourcesRepository _resourceRepository;
  final Authentication _authentication;
  final String resourceId;

  ResourceElementCreateCubit(
    this._resourceRepository,
    this._authentication, {
    required this.resourceId,
  }) : super(ResourceElementCreateLoading()) {
    _init();
  }

  Future<void> _init() async {
    emit(ResourceElementCreateLoading());
    try {
      final resource = await _resourceRepository.getDescription(
        _authentication,
        resourceId,
      );

      final fields = resource.fields.where((f) => !f.readOnly).toList();

      if (!isClosed) {
        emit(
          ResourceElementCreateEditing(
            fields: fields,
            changes: {},
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
      final field = fields.firstWhere((e) => e.id == fieldId);
      if (field.readOnly) {
        return;
      }

      final fieldValidation = validateFieldValue(field, value);
      final validation = <ResourceField, String>{
        if (state case ResourceElementCreateEditing(:final validation))
          ...validation,
      };

      if (fieldValidation == null) {
        validation.remove(field);
      } else {
        validation[field] = fieldValidation;
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

  Future<void> saveChanges({DateTime? revisionLive}) async {
    if (state case final ResourceElementCreateValue state
        when state is! ResourceElementCreateSaving &&
            state.changes.isNotEmpty) {
      try {
        // TODO validate all
        final savingState = state.saving();
        emit(savingState);
        final updated = await _resourceRepository.createElement(
          _authentication,
          resourceId,
          state.changes.map((key, value) => MapEntry(key.id, value)),
          revisionLive,
        );
        decodeFieldData(state.description, updated);

        emit(savingState.saved(updated.id, updated.revisionId));
      } catch (e) {
        emit(ResourceElementCreateError(message: e.toString()));
      }
    }
  }
}
