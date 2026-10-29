part of 'resource_element_create_cubit.dart';

sealed class ResourceElementCreateState;

final class ResourceElementCreateLoading extends ResourceElementCreateState;

abstract class ResourceElementCreateValue extends ResourceElementCreateState {
  final ResourceDescription description;
  final List<ResourceField> fields;
  final Map<ResourceField, dynamic> changes;
  final Map<ResourceField, dynamic> defaults;

  ResourceElementCreateValue({
    required this.description,
    required this.fields,
    required this.changes,
    required this.defaults,
  });

  ResourceElementCreateSaving saving() => ResourceElementCreateSaving(
    fields: fields,
    changes: changes,
    defaults: defaults,
    description: description,
  );
}

final class ResourceElementCreateEditing extends ResourceElementCreateValue {
  final Map<String, String> validation;

  bool get isValid => validation.isEmpty;

  ResourceElementCreateEditing({
    required super.description,
    required super.fields,
    required super.changes,
    required super.defaults,
    required this.validation,
  });
}

final class ResourceElementCreateSaving extends ResourceElementCreateValue {
  ResourceElementCreateSaving({
    required super.description,
    required super.fields,
    required super.changes,
    required super.defaults,
  });

  ResourceElementCreateState saved(String id, int? version) =>
      ResourceElementCreateSaved(
        fields: fields,
        changes: changes,
        defaults: defaults,
        id: id,
        version: version,
        description: description,
      );
}

final class ResourceElementCreateSaved extends ResourceElementCreateValue {
  final String id;
  final int? version;

  ResourceElementCreateSaved({
    required this.id,
    required this.version,
    required super.fields,
    required super.changes,
    required super.defaults,
    required super.description,
  });
}

final class ResourceElementCreateError extends ResourceElementCreateState {
  final String? message;

  ResourceElementCreateError({this.message});
}
