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
      // Read-only fields without a value source on creation still have to be
      // provided by the user, otherwise the element can't be created.
      final fields = [
        for (final field in resource.fields)
          if (!field.readOnly)
            field
          else if (!field.auto && !field.nullable && field.defaultValue == null)
            field.copyWith(readOnly: false),
      ];
      final defaults = <ResourceField, dynamic>{
        for (final field in fields)
          if (!field.readOnly && field.defaultValue != null)
            field: decodeFieldValue(field, field.defaultValue),
      };
      for (final field in fields.where(
        (e) => e.type == ResourceFieldType.list,
      )) {
        defaults.putIfAbsent(field, () => []);
      }

      if (!isClosed) {
        emit(
          ResourceElementCreateEditing(
            fields: fields,
            changes: Map.of(defaults),
            defaults: defaults,
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
      :final defaults,
      :final description,
    )) {
      final field = fields.firstWhere((f) => f.id == fieldId);

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
          defaults: defaults,
          validation: validation,
          description: description,
        ),
      );
    }
  }

  /// Sets the value of a field back to the one it started with, see
  /// [ResourceElementCreateValue.defaults].
  void resetFieldValue(String fieldId) {
    if (state case ResourceElementCreateValue(
      :final fields,
      :final changes,
      :final defaults,
      :final description,
    )) {
      final field = fields.firstWhere((f) => f.id == fieldId);
      if (defaults.containsKey(field)) {
        return setFieldValue(fieldId, defaults[field]);
      }

      // Without a default the field is left out, not set to null.
      emit(
        ResourceElementCreateEditing(
          fields: fields,
          changes: Map.of(changes)..remove(field),
          defaults: defaults,
          validation: {
            if (state case ResourceElementCreateEditing(:final validation))
              ...validation,
          }..removeWhere((path, _) => isPathWithin(path, field.id)),
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
          for (final field in state.fields)
            field.id: ?validateFieldValue(field, state.changes[field]),
        };

        if (validation.isNotEmpty) {
          return emit(
            ResourceElementCreateEditing(
              fields: state.fields,
              changes: state.changes,
              defaults: state.defaults,
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
        if (editableFieldErrors(e, state.fields) case final errors?) {
          emit(
            ResourceElementCreateEditing(
              description: state.description,
              fields: state.fields,
              changes: state.changes,
              defaults: state.defaults,
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
