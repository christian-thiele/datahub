part of 'resource_element_create_cubit.dart';

@immutable
sealed class ResourceElementCreateState {}

final class ResourceElementCreateLoading extends ResourceElementCreateState {}

abstract class ResourceElementCreateValue extends ResourceElementCreateState {
  final ResourceDescription description;
  final List<ResourceField> fields;
  final Map<ResourceField, dynamic> changes;

  ResourceElementCreateValue({
    required this.description,
    required this.fields,
    required this.changes,
  });

  ResourceElementCreateSaving saving() => ResourceElementCreateSaving(
    fields: fields,
    changes: changes,
    description: description,
  );
}

final class ResourceElementCreateEditing extends ResourceElementCreateValue {
  final Map<ResourceField, String> validation;

  bool get isValid => validation.isEmpty;

  ResourceElementCreateEditing({
    required super.description,
    required super.fields,
    required super.changes,
    required this.validation,
  });
}

final class ResourceElementCreateSaving extends ResourceElementCreateValue {
  ResourceElementCreateSaving({
    required super.description,
    required super.fields,
    required super.changes,
  });

  ResourceElementCreateState saved(String id, String? revisionId) =>
      ResourceElementCreateSaved(
        fields: fields,
        changes: changes,
        id: id,
        revisionId: revisionId,
        description: description,
      );
}

final class ResourceElementCreateSaved extends ResourceElementCreateValue {
  final String id;
  final String? revisionId;

  ResourceElementCreateSaved({
    required this.id,
    required this.revisionId,
    required super.fields,
    required super.changes,
    required super.description,
  });
}

final class ResourceElementCreateError extends ResourceElementCreateState {
  final String? message;

  ResourceElementCreateError({this.message});
}
