import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:bloc/bloc.dart';

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
      final field = description.getField(fieldId);
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
        when state is! ResourceElementCreateSaving) {
      try {
        final validation = <ResourceField, String>{
          for (final field in state.description.fields)
            if (validateFieldValue(field, state.changes[field])
                case final error?)
              field: error,
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
          revisionLive,
        );
        decodeFieldData(state.description, updated);

        emit(savingState.saved(updated.id, updated.revisionId));
      } catch (e) {
        if (e case ApiRequestException(
          data: {'fields': final Map<String, dynamic> fieldErrors},
        )) {
          try {
            if (fieldErrors.keys.any(
              (e) => state.description.getField(e).readOnly,
            )) {
              return emit(ResourceElementCreateError(message: e.toString()));
            }

            emit(
              ResourceElementCreateEditing(
                description: state.description,
                fields: state.fields,
                changes: state.changes,
                validation: {
                  for (final (field, errors) in fieldErrors.tuples)
                    state.description.getField(field): errors.first,
                },
              ),
            );
          } catch (e) {
            emit(ResourceElementCreateError(message: e.toString()));
          }
        } else {
          emit(ResourceElementCreateError(message: e.toString()));
        }
      }
    }
  }
}
