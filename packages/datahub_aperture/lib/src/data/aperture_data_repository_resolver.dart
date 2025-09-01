import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_resource_repository.dart';

class ApertureDataRepositoryResolver<T extends DataObject<T>,
    Repo extends DataRepository<T>> implements ApertureResourceWriteRepository {
  const ApertureDataRepositoryResolver();

  @override
  Future<ResourceData> createElement(
      Map<String, dynamic> data, DateTime? revisionLive) async {
    final repo = resolve<Repo>();
    final object = await repo.create(repo.bean.fromJson(data));
    return _toResourceData(object);
  }

  @override
  Future<ResourceData> getElement(String id, String? revisionId) async {
    final repo = resolve<Repo>();
    final object = await repo.get(id);

    if (object == null) {
      throw ApiRequestException.notFound();
    }

    return _toResourceData(object);
  }

  @override
  Future<ResourceElementsResponse> getElements(
    ResourceFilter? filter,
    int offset,
    int limit,
  ) async {
    // TODO sort
    final repo = resolve<Repo>();

    final elements = await repo.getAll(
      filter: _buildFilter(filter),
      offset: offset,
      limit: limit + 1,
    );
    return ResourceElementsResponse(
      total: null,
      hasNextPage: elements.length > limit,
      data: elements.take(limit).map(_toResourceData).toList(),
    );
  }

  @override
  Future<ResourceData> updateElement(
      String id, Map<String, dynamic> data, DateTime? revisionLive) async {
    final repo = resolve<Repo>();
    final existing = await repo.get(id);
    if (existing == null) {
      throw ApiRequestException.notFound();
    }

    final combined = {
      ...existing.toJson(),
      ...data,
    };

    final updated = await repo.update(id, repo.bean.fromJson(combined));
    return _toResourceData(updated);
  }

  @override
  Future<ResourceData> deleteElement(
    String id,
    DateTime? revisionLive,
  ) async {
    final repo = resolve<Repo>();
    await repo.delete(id);
    // TODO what to return here?
    return ResourceData(id: id, fieldData: {});
  }

  ResourceData _toResourceData(T object) {
    final bean = resolve<Repo>().bean;
    final idField = bean.idField ?? (throw MissingIdFieldError(bean));
    return ResourceData(
      id: idField.valueOf(object).toString(),
      fieldData: object.toJson(),
    );
  }

  Filter _buildFilter(ResourceFilter? filter) {
    final bean = resolve<Repo>().bean;
    if (filter == null) {
      return Filter.empty;
    }

    final Filter elementFilter;
    if (filter
        case ResourceFilter(:final type?, :final fieldId?, :final value)) {
      final field = bean.fields.firstWhere((e) => e.name == fieldId);
      elementFilter = CompareFilter(
        FieldExpression(field),
        switch (type) {
          ResourceFilterType.equals => CompareType.equals,
          ResourceFilterType.notEquals => CompareType.notEquals,
          ResourceFilterType.greaterThan => CompareType.greaterThan,
          ResourceFilterType.lessThan => CompareType.lessThan,
          ResourceFilterType.contains => CompareType.contains,
        },
        ValueExpression(_alignFieldValue(field, value)),
      );
    } else {
      elementFilter = Filter.empty;
    }

    return Filter.andGroup([
      Filter.andGroup((filter.and ?? <ResourceFilter>[]).map(_buildFilter)),
      Filter.andGroup((filter.or ?? <ResourceFilter>[]).map(_buildFilter)),
      elementFilter,
    ]);
  }

  // TODO find a way not to need this?
  dynamic _alignFieldValue(DataField<T, dynamic> field, String? value) {
    if (field.type.accepts(value)) {
      return value;
    }

    return const JsonDataCodec().decodeType(field.type, value);
  }
}
