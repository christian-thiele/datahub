import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';

const people = ResourceDescription(
  id: 'Person',
  name: 'Person',
  icon: 0xe491,
  fields: [
    ResourceField(id: 'id', name: 'Id', type: ResourceFieldType.int),
    ResourceField(id: 'name', name: 'Name', type: ResourceFieldType.string),
  ],
  relations: [],
  idField: 'id',
  displayField: 'name',
  readOnly: false,
  revisable: false,
  actions: [],
);

/// Serves the elements of [resource] to look up.
///
/// Like the backend does with filters it can not apply, it ignores filters and
/// serves all elements.
class LookupRepository implements ResourcesRepository {
  final ResourceDescription resource;
  final List<Map<String, dynamic>> elements;

  /// How long requesting elements takes.
  final Duration delay;

  /// The filters elements were requested with.
  final filters = <ResourceFilter?>[];

  LookupRepository(this.resource, this.elements, {this.delay = Duration.zero});

  @override
  Future<ResourceDescription> getDescription(String id) async => resource;

  @override
  Future<ResourceElementsResponse> getResourceElements(
    String resourceId, {
    ResourceFilter? filter,
    String? sortFieldId,
    bool sortAscending = true,
    int offset = 0,
    int limit = 25,
  }) async {
    filters.add(filter);
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    return ResourceElementsResponse(
      total: elements.length,
      hasNextPage: false,
      data: [
        for (final element in elements)
          ResourceData(
            id: '${element[resource.idField]}',
            fieldData: {...element},
          ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
