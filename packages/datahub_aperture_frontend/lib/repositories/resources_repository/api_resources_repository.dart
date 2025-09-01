import 'dart:convert';

import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/authentication.dart';
import 'package:datahub/datahub.dart';
import 'resources_repository.dart';

class ApiResourcesRepository implements ResourcesRepository {
  late final RestClient _restClient;

  @override
  Future<void> initialize() async {
    _restClient = await RestClient.connect(Uri.parse('http://localhost:8080'));
  }

  @override
  Future<void> close() async {
    await _restClient.close();
  }

  @override
  Future<ResourceData> createElement(
    Authentication authentication,
    String resourceId,
    Map<String, dynamic> changes,
    DateTime? revisionLive,
  ) async {
    return await _restClient
        .post(
          '/api/resources/{resourceId}/elements',
          ResourceRevisionRequest(
            fieldData: changes,
            revisionLive: revisionLive,
          ),
          urlParams: {'resourceId': resourceId},
        )
        .thenGetData(ResourceData.bean);
  }

  @override
  Future<ResourceDescription> getDescription(
    Authentication auth,
    String id,
  ) async {
    final result = await _restClient.get(
      '/api/resources/{id}',
      urlParams: {'id': id},
    );
    return await result.getData(ResourceDescription.bean);
  }

  @override
  Future<List<ResourceDescription>> getDescriptions(Authentication auth) async {
    final result = await _restClient.get('/api/resources');
    return await result.getList(ResourceDescription.bean);
  }

  @override
  Future<ResourceData> getResourceElement(
    Authentication auth,
    String resourceId,
    String elementId, {
    String? revisionId,
  }) async {
    return await _restClient
        .get(
          '/api/resources/{resourceId}/elements/{elementId}',
          urlParams: {'resourceId': resourceId, 'elementId': elementId},
          query: {
            if (revisionId != null) 'revisionId': [revisionId],
          },
        )
        .thenGetData(ResourceData.bean);
  }

  @override
  Future<ResourceElementsResponse> getResourceElements(
    Authentication authentication,
    String resourceId, {
    ResourceFilter? filter,
    int offset = 0,
    int limit = 25,
  }) async {
    return await _restClient
        .get(
          '/api/resources/{resourceId}/elements',
          urlParams: {'resourceId': resourceId},
          query: {
            'offset': [offset.toString()],
            'limit': [limit.toString()],
            if (filter != null) 'filter': [jsonEncode(filter)],
          },
        )
        .thenGetData(ResourceElementsResponse.bean);
  }

  @override
  Future<ResourceData> updateElement(
    Authentication auth,
    String resourceId,
    String elementId,
    Map<String, dynamic> changes,
    DateTime? revisionLive,
  ) async {
    return await _restClient
        .patch(
          '/api/resources/{resourceId}/elements/{elementId}',
          ResourceRevisionRequest(
            fieldData: changes,
            revisionLive: revisionLive,
          ),
          urlParams: {'resourceId': resourceId, 'elementId': elementId},
        )
        .thenGetData(ResourceData.bean);
  }
}
