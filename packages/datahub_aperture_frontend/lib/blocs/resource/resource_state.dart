part of 'resource_cubit.dart';

@immutable
sealed class ResourceState {
  final FilterState? filter;
  final int offset;
  final int? total;
  final int pageSize;

  const ResourceState({
    required this.filter,
    required this.offset,
    required this.total,
    required this.pageSize,
  });

  ResourceError error({String? message}) => ResourceError(
    offset: offset,
    total: total,
    pageSize: pageSize,
    message: message,
    filter: filter,
  );

  ResourceLoading loading() => ResourceLoading(
    offset: offset,
    total: total,
    pageSize: pageSize,
    filter: filter,
  );
}

final class ResourceLoading extends ResourceState {
  final bool _initial;

  const ResourceLoading({
    bool initial = false,
    required super.filter,
    required super.offset,
    required super.total,
    required super.pageSize,
  }) : _initial = initial;
}

final class ResourceValue extends ResourceState {
  final ResourceDescription resource;
  final bool hasNextPage;
  final List<ResourceData> data;

  const ResourceValue({
    required this.resource,
    required this.hasNextPage,
    required this.data,
    required super.pageSize,
    required super.offset,
    required super.total,
    required super.filter,
  });
}

final class ResourceError extends ResourceState {
  final String? message;

  const ResourceError({
    this.message,
    required super.filter,
    required super.offset,
    required super.total,
    required super.pageSize,
  });
}
