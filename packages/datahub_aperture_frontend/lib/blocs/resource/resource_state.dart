part of 'resource_cubit.dart';

sealed class ResourceState {
  final FilterState filter;
  final Paging paging;

  const ResourceState({required this.filter, required this.paging});

  ResourceError error({String? message}) =>
      ResourceError(paging: paging, message: message, filter: filter);

  ResourceLoading loading() => ResourceLoading(paging: paging, filter: filter);
}

final class ResourceLoading extends ResourceState {
  final bool _initial;

  const ResourceLoading({
    bool initial = false,
    required super.filter,
    required super.paging,
  }) : _initial = initial;
}

final class ResourceValue extends ResourceState {
  final ResourceDescription resource;
  final List<ResourceData> data;

  const ResourceValue({
    required this.resource,
    required this.data,
    required super.paging,
    required super.filter,
  });
}

final class ResourceError extends ResourceState implements ErrorState {
  @override
  final String? message;

  const ResourceError({
    this.message,
    required super.filter,
    required super.paging,
  });
}
