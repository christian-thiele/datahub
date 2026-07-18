import 'dart:convert';

import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture_frontend/repositories/api_repository.dart';
import 'resources_repository.dart';

class ApiResourcesRepository extends ApiRepository
    implements ResourcesRepository {
  ApiResourcesRepository({required super.baseUrl});

  @override
  Future<ResourceData> createElement(
    String resourceId,
    Map<String, dynamic> changes,
    DateTime? from,
  ) async {
    final client = await getClient();
    return await client
        .post(
          '/api/resources/{resourceId}/elements',
          ResourceRevisionRequest(fieldData: changes, from: from),
          urlParams: {'resourceId': resourceId},
        )
        .thenGetData($ResourceData.bean);
  }

  @override
  Future<ResourceDescription> getDescription(String id) async {
    final client = await getClient();
    final result = await client.get(
      '/api/resources/{id}',
      urlParams: {'id': id},
    );
    return await result.getData($ResourceDescription.bean);
  }

  @override
  Future<List<ResourceDescription>> getDescriptions() async {
    final client = await getClient();
    final result = await client.get('/api/resources');
    return await result.getList($ResourceDescription.bean);
  }

  @override
  Future<List<ModuleDescription>> getModules() async {
    final client = await getClient();
    final result = await client.get('/api/modules');
    return await result.getList($ModuleDescription.bean);
  }

  @override
  Future<ResourceData> getResourceElement(
    String resourceId,
    String elementId, {
    int? version,
  }) async {
    final client = await getClient();
    return await client
        .get(
          '/api/resources/{resourceId}/elements/{elementId}',
          urlParams: {'resourceId': resourceId, 'elementId': elementId},
          query: {
            if (version != null) 'version': [version.toString()],
          },
        )
        .thenGetData($ResourceData.bean);
  }

  @override
  Future<ResourceElementsResponse> getResourceElements(
    String resourceId, {
    ResourceFilter? filter,
    String? sortFieldId,
    bool sortAscending = true,
    int offset = 0,
    int limit = 25,
  }) async {
    final client = await getClient();
    return await client
        .get(
          '/api/resources/{resourceId}/elements',
          urlParams: {'resourceId': resourceId},
          query: {
            'offset': [offset.toString()],
            'limit': [limit.toString()],
            if (filter != null) 'filter': [jsonEncode(filter)],
            if (sortFieldId != null) 'sort': [sortFieldId],
            if (sortFieldId != null) 'asc': [sortAscending.toString()],
          },
        )
        .thenGetData($ResourceElementsResponse.bean);
  }

  @override
  Future<ResourceData> updateElement(
    String resourceId,
    String elementId,
    Map<String, dynamic> changes,
    DateTime? from,
  ) async {
    final client = await getClient();
    return await client
        .patch(
          '/api/resources/{resourceId}/elements/{elementId}',
          ResourceRevisionRequest(fieldData: changes, from: from),
          urlParams: {'resourceId': resourceId, 'elementId': elementId},
        )
        .thenGetData($ResourceData.bean);
  }

  @override
  Future<ResourceData?> deleteElement(
    String resourceId,
    String elementId,
    DateTime? from,
  ) async {
    final client = await getClient();
    final response = await client.delete(
      '/api/resources/{resourceId}/elements/{elementId}',
      urlParams: {'resourceId': resourceId, 'elementId': elementId},
      query: {
        if (from != null) 'from': [from.toIso8601String()],
      },
    );

    try {
      return await response.getData($ResourceData.bean);
    } on ApiException catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> startElementAction(
    String resourceId,
    String elementId,
    String actionId,
  ) async {
    final client = await getClient();
    return client
        .post(
          '/api/resources/{resourceId}/elements/{elementId}/actions/{actionId}',
          {},
          urlParams: {
            'resourceId': resourceId,
            'elementId': elementId,
            'actionId': actionId,
          },
        )
        .thenGetJsonBody();
  }
}
