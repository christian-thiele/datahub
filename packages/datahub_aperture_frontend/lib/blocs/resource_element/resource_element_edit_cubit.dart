import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture_frontend/models/filtered_resource.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:bloc/bloc.dart';

part 'resource_element_edit_state.dart';

class ResourceElementEditCubit extends Cubit<ResourceElementEditState> {
  final ResourcesRepository _resourceRepository;
  final String resourceId;
  final String elementId;
  final int? version;

  ResourceElementEditCubit(
    this._resourceRepository, {
    required this.resourceId,
    required this.elementId,
    this.version,
  }) : super(ResourceElementEditLoading(initial: true)) {
    update();
  }

  Future<void> update() async {
    if (state case ResourceElementEditLoading(_initial: false)) {
      return;
    }

    emit(ResourceElementEditLoading());
    try {
      final resource = await _resourceRepository.getDescription(resourceId);

      final data = await _resourceRepository.getResourceElement(
        resourceId,
        elementId,
        version: version,
      );
      decodeFieldData(resource, data);

      final relations = [
        for (final relation in resource.relations)
          FilteredResource(
            resourceId: relation.resourceId,
            name: relation.name,
            filter: buildFilter(relation.filter, data),
          ),
      ];

      final displayName =
          data.fieldData[resource.displayField ?? resource.idField]
              ?.toString() ??
          resource.name;

      if (!isClosed) {
        emit(
          ResourceElementEditValue(
            title: displayName,
            resource: resource,
            data: data,
            relations: relations,
            validations: {},
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(ResourceElementEditError(message: e.toString()));
      }
    }
  }

  void setFieldValue(String fieldId, dynamic value) {
    if (state case ResourceElementEditValue(
      :final resource,
      :final data,
      :final changes,
      :final relations,
      :final title,
    )) {
      final field = resource.fields.firstWhere((e) => e.id == fieldId);
      if (field.readOnly) {
        return;
      }

      final fieldValidation = validateFieldValue(field, value);
      final validation = <ResourceField, String>{
        if (state case ResourceElementEditValue(:final validations))
          ...validations,
      };

      if (fieldValidation == null) {
        validation.remove(field);
      } else {
        validation[field] = fieldValidation;
      }

      if (data.fieldData[fieldId] == value) {
        emit(
          ResourceElementEditValue(
            resource: resource,
            data: data,
            changes: Map.of(changes)..remove(field),
            relations: relations,
            title: title,
            validations: validation,
          ),
        );
      } else {
        emit(
          ResourceElementEditValue(
            title: title,
            resource: resource,
            data: data,
            relations: relations,
            changes: {...changes, field: value},
            validations: validation,
          ),
        );
      }
    }
  }

  Future<void> revertToRevision(int version) async {
    if (state case final ResourceElementEditValue state
        when state is! ResourceElementEditSaving) {
      try {
        final revisionData = await _resourceRepository.getResourceElement(
          resourceId,
          elementId,
          version: version,
        );

        final newChanges = <ResourceField, dynamic>{};
        for (final field in state.resource.fields) {
          if (!field.readOnly) {
            newChanges[field] = revisionData.fieldData[field.id];
          }
        }

        emit(
          ResourceElementEditValue(
            title: state.title,
            resource: state.resource,
            data: state.data,
            relations: state.relations,
            changes: newChanges,
            validations: {},
          ),
        );
      } catch (e) {
        emit(ResourceElementEditError(message: e.toString()));
      }
    }
  }

  Future<void> saveChanges({DateTime? from}) async {
    if (state case final ResourceElementEditValue state
        when state is! ResourceElementEditSaving && state.changes.isNotEmpty) {
      try {
        final validation = <ResourceField, String>{
          for (final field in state.resource.fields)
            if (validateFieldValue(
                  field,
                  state.changes[field] ?? state.data.fieldData[field.id],
                )
                case final error?)
              field: error,
        };

        if (validation.isNotEmpty) {
          return emit(
            ResourceElementEditValue(
              title: state.title,
              resource: state.resource,
              data: state.data,
              relations: state.relations,
              changes: state.changes,
              validations: validation,
            ),
          );
        }

        final savingState = state.saving();
        emit(savingState);
        final updated = await _resourceRepository.updateElement(
          resourceId,
          elementId,
          state.changes.map((k, v) => MapEntry(k.id, v)),
          from,
        );
        decodeFieldData(state.resource, updated);
        emit(savingState.saved(updated));
      } catch (e) {
        if (e case ApiRequestException(
          data: {'fields': final Map<String, dynamic> fieldErrors},
        )) {
          if (fieldErrors.keys.any(
            (e) => state.resource.getField(e).readOnly,
          )) {
            return emit(ResourceElementEditError(message: e.toString()));
          }

          emit(
            ResourceElementEditValue(
              title: state.title,
              resource: state.resource,
              data: state.data,
              relations: state.relations,
              changes: state.changes,
              validations: {
                for (final (field, errors) in fieldErrors.tuples)
                  state.resource.fields.firstWhere((e) => e.id == field):
                      errors.first,
              },
            ),
          );
        } else {
          emit(ResourceElementEditError(message: e.toString()));
        }
      }
    }
  }

  Future<void> delete({DateTime? from}) async {
    if (state case final ResourceElementEditValue state) {
      try {
        final savingState = state.saving();
        emit(savingState);
        final updated = await _resourceRepository.deleteElement(
          resourceId,
          elementId,
          from,
        );
        if (updated != null) {
          decodeFieldData(state.resource, updated);
          emit(savingState.saved(updated));
        } else {
          emit(ResourceElementEditDeleted());
        }
      } catch (e) {
        emit(ResourceElementEditError(message: e.toString()));
      }
    }
  }
}
