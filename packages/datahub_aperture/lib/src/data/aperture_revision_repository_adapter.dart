/*
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_resource_repository.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class ApertureRevisionRepositoryAdapter<T extends DataObject,
    Repo extends DataRepository<T>> implements ApertureResourceWriteRepository {
  final Find<RevisionRepository<T>> repository;

  ApertureRevisionRepositoryAdapter({
    required this.repository,
  });

  @override
  Future<ResourceData> createElement(
    Map<String, dynamic> data,
    DateTime? revisionLive,
  ) async {
    final repo = repository.find();
    final T object;
    try {
      object = repo.bean.fromJson(data);
    } on CodecException catch (e) {
      _throwCodecApiException(e);
    }

    repo.bean.validateConstraints(object);

    final DataRevision<T> result;
    result = await repo.createRevision(
      object,
      type: 1,
      live: revisionLive,
    );

    return _toResourceData(result);
  }

  @override
  Future<ResourceData> getElement(String id, String? revisionId) async {
    final repo = Context.ofZone().find(repository);
    final revision = await repo.getData(id, revisionId: revisionId);

    if (revision == null) {
      throw ApiRequestException.notFound();
    }

    final revisions = await repo.getRevisions(id);
    return _toResourceData(revision, revisions);
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
    final existing = await repo.getData(id);
    if (existing == null) {
      throw ApiRequestException.notFound();
    }

    final combined = {
      ...existing.data.toJson(),
      ...data,
    };

    final T object;
    try {
      object = repo.bean.fromJson(combined);
    } on CodecException catch (e) {
      _throwCodecApiException(e);
    }

    repo.bean.validateConstraints(object);

    final updated = await repo.createRevision(
      object,
      type: 0,
      live: revisionLive,
    );

    final revisions = await repo.getRevisions(id);
    return _toResourceData(updated, revisions);
  }

  @override
  Future<ResourceData?> deleteElement(
    String id,
    DateTime? revisionLive,
  ) async {
    final repo = repository.find();
    final data = await repo.getData(id);
    if (data == null) {
      throw ApiRequestException.notFound();
    }

    final result = await repo.createRevision(
      data.data,
      type: -1,
      live: revisionLive,
    );
    final revisions = await repo.getRevisions(id);
    return _toResourceData(result, revisions);
  }

  ResourceData _toResourceData(
    DataRevision<T> object, [
    List<DataRevision<T>>? revisions,
  ]) {
    final repo = repository.find();
    return ResourceData(
      id: repo.bean.requireIdField.valueOf(object.data).toString(),
      fieldData: object.data.toJson(),
      revisionId: object.id,
      revisions: [
        if (revisions != null)
          for (final revision in revisions)
            ResourceRevisionInfo(
              id: revision.id,
              type: switch (revision.type) {
                < 0 => ResourceRevisionType.delete,
                > 0 => ResourceRevisionType.create,
                _ => ResourceRevisionType.update,
              },
              timestamp: revision.timestamp,
              live: revision.live,
              userId: revision.by,
              userName: revision.by,
            ),
      ],
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
  dynamic _alignFieldValue(DataField<T, dynamic> field, String? value) {
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
*/
