import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_resource_repository.dart';

class ApertureDataRepositoryAdapter implements ApertureResourceWriteRepository {
  final Find<DataRepository> repository;

  ApertureDataRepositoryAdapter({
    required this.repository,
  });

  @override
  Future<ResourceData> createElement(
    Map<String, dynamic> data,
    DateTime? revisionLive,
  ) async {
    final repo = repository.find();
    final dynamic object;
    try {
      object = repo.bean.fromJson(data);
    } on CodecException catch (e) {
      _throwCodecApiException(e);
    }

    repo.bean.validateConstraints(object);

    final result = await repo.create(object);
    return _toResourceData(result);
  }

  @override
  Future<ResourceData> getElement(String id, String? revisionId) async {
    final repo = repository.find();
    final dynamic? object = await repo.get(id);

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
    final repo = repository.find();

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
    String id,
    Map<String, dynamic> data,
    DateTime? revisionLive,
  ) async {
    final repo = repository.find();
    final existing = await repo.get(id);
    if (existing == null) {
      throw ApiRequestException.notFound();
    }

    final combined = {
      ...existing.toJson(),
      ...data,
    };

    final dynamic object;
    try {
      object = repo.bean.fromJson(combined);
    } on CodecException catch (e) {
      _throwCodecApiException(e);
    }

    repo.bean.validateConstraints(object);

    final dynamic updated;
    updated = await repo.update(id, object);

    return _toResourceData(updated);
  }

  @override
  Future<ResourceData?> deleteElement(
    String id,
    DateTime? revisionLive,
  ) async {
    final repo = repository.find();
    await repo.delete(id);
    return null;
  }

  ResourceData _toResourceData(dynamic object) {
    final repo = repository.find();
    return ResourceData(
      id: repo.bean.requireIdField.valueOf(object).toString(),
      fieldData: object.toJson(),
    );
  }

  Filter _buildFilter(ResourceFilter? filter) {
    try {
      final repo = repository.find();
      final bean = repo.bean;
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
        Filter.orGroup((filter.or ?? <ResourceFilter>[]).map(_buildFilter)),
        elementFilter,
      ]);
    } catch (e) {
      log.warn('Filter error: ${e.toString()}');
      return Filter.empty;
    }
  }

  // TODO find a way not to need this?
  dynamic _alignFieldValue(DataField<dynamic, dynamic> field, String? value) {
    if (field.type.accepts(value)) {
      return value;
    }

    if (field.type.isSubtypeOf<List?>()) {
      return value;
    }

    return const JsonDataCodec().decodeType(field.type, value);
  }

  Never _throwCodecApiException(CodecException e) {
    throw ApiRequestException(
      400,
      e.message,
      data: {
        if (e.name != null)
          'fields': {
            e.name: [e.message],
          },
      },
    );
  }
}
