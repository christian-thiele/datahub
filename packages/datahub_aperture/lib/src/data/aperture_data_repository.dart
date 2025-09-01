import 'package:datahub/data.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_resource_repository.dart';
import 'package:datahub_aperture/src/aperture_service/models/api/resource_data.dart';
import 'package:datahub_aperture/src/aperture_service/models/api/resource_elements_response.dart';
import 'package:datahub_aperture/src/aperture_service/models/api/resource_filter.dart';

class ApertureDataRepositoryDelegate<T extends DataObject<T>,
    Repo extends DataRepository<T>> implements ApertureResourceWriteRepository {
  final DataBean<T> bean;

  ApertureDataRepositoryDelegate(this.bean);

  @override
  Future<ResourceData> createElement(
      Map<String, dynamic> data, DateTime? revisionLive) async {
    final repo = resolve<Repo>();
    final object = await repo.create(bean.fromJson(data));
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
    // TODO filter, sort
    final repo = resolve<Repo>();
    final elements = await repo.getAll(offset: offset, limit: limit + 1);
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
    final updated = await repo.update(id, bean.fromJson(data));
    return _toResourceData(updated);
  }

  ResourceData _toResourceData(T object) {
    // TODO id thing
    final id = bean.fields.firstWhere((e) => e.name == 'id').valueOf(object);
    return ResourceData(id: id.toString(), fieldData: object.toJson());
  }
}
