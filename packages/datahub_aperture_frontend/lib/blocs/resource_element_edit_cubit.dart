import 'package:datahub_aperture_frontend/models/authentication.dart';
import 'package:datahub_aperture_frontend/models/filtered_resource.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'resource_element_edit_state.dart';

class ResourceElementEditCubit extends Cubit<ResourceElementEditState> {
  final ResourcesRepository _resourceRepository;
  final Authentication _authentication;
  final String resourceId;
  final String elementId;
  final String? revisionId;

  ResourceElementEditCubit(
    this._resourceRepository,
    this._authentication, {
    required this.resourceId,
    required this.elementId,
    this.revisionId,
  }) : super(ResourceElementEditLoading(initial: true)) {
    update();
  }

  Future<void> update() async {
    if (state case ResourceElementEditLoading(_initial: false)) {
      return;
    }

    emit(ResourceElementEditLoading());
    try {
      final resource = await _resourceRepository.getDescription(
        _authentication,
        resourceId,
      );

      final data = await _resourceRepository.getResourceElement(
        _authentication,
        resourceId,
        elementId,
        revisionId: revisionId,
      );

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

  Future<void> saveChanges({DateTime? revisionLive}) async {
    if (state case final ResourceElementEditValue state
        when state is! ResourceElementEditSaving && state.changes.isNotEmpty) {
      try {
        final savingState = state.saving();
        emit(savingState);
        final updated = await _resourceRepository.updateElement(
          _authentication,
          resourceId,
          elementId,
          state.changes.map((k, v) => MapEntry(k.id, v)),
          revisionLive,
        );
        emit(savingState.saved(updated));
      } catch (e) {
        emit(ResourceElementEditError(message: e.toString()));
      }
    }
  }

  void startAction(String id) {}

  void delete() {}
}
