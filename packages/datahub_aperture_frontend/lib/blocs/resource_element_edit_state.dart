part of 'resource_element_edit_cubit.dart';

@immutable
sealed class ResourceElementEditState {
  const ResourceElementEditState();
}

final class ResourceElementEditLoading extends ResourceElementEditState {
  final bool _initial;

  const ResourceElementEditLoading({bool initial = false}) : _initial = initial;
}

final class ResourceElementEditValue extends ResourceElementEditState {
  final String title;
  final ResourceDescription resource;
  final ResourceData data;
  final Map<ResourceField, dynamic> changes;
  final Map<ResourceField, String> validations;
  final List<FilteredResource> relations;

  const ResourceElementEditValue({
    required this.title,
    required this.resource,
    required this.data,
    required this.relations,
    required this.validations,
    this.changes = const {},
  });

  ResourceElementEditSaving saving() => ResourceElementEditSaving(
    title: title,
    resource: resource,
    data: data,
    changes: changes,
    relations: relations,
    validations: {},
  );
}

final class ResourceElementEditSaving extends ResourceElementEditValue {
  const ResourceElementEditSaving({
    required super.title,
    required super.resource,
    required super.data,
    required super.changes,
    required super.relations,
    required super.validations,
  });

  ResourceElementEditSaved saved(ResourceData data) => ResourceElementEditSaved(
    title: title,
    resource: resource,
    data: data,
    relations: relations,
    validations: {},
  );
}

final class ResourceElementEditSaved extends ResourceElementEditValue {
  const ResourceElementEditSaved({
    required super.title,
    required super.resource,
    required super.data,
    required super.relations,
    required super.validations,
  });
}

final class ResourceElementEditError extends ResourceElementEditState {
  final String? message;

  const ResourceElementEditError({this.message});
}
