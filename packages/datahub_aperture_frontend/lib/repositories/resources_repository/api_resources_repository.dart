import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture_frontend/services.dart';
import 'resources_repository.dart';

class ApiResourcesRepository implements ResourcesRepository {
  final String baseUrl;
  late final Lazy<RestClient> _restClient = Lazy(
    () => RestClient.connect(
      Uri.parse(baseUrl),
      timeout: const Duration(seconds: 10),
    ),
  );

  ApiResourcesRepository({required this.baseUrl});

  Future<void> _updateAuth() async {
    final client = await _restClient.get();
    client.auth = await AuthService.instance.getValidAccessToken();
  }

  Future<void> close() async {
    if (_restClient.isInitialized) {
      final client = await _restClient.get();
      _restClient.invalidate();
      await client.close();
    }
  }

  @override
  Future<ResourceData> createElement(
    String resourceId,
    Map<String, dynamic> changes,
    DateTime? revisionLive,
  ) async {
    await _updateAuth();
    final client = await _restClient.get();
    return await client
        .post(
          '/api/resources/{resourceId}/elements',
          ResourceRevisionRequest(
            fieldData: changes,
            revisionLive: revisionLive,
          ),
          urlParams: {'resourceId': resourceId},
        )
        .thenGetData($ResourceData.bean);
  }

  @override
  Future<ResourceDescription> getDescription(String id) async {
    await _updateAuth();
    final client = await _restClient.get();
    final result = await client.get(
      '/api/resources/{id}',
      urlParams: {'id': id},
    );
    return await result.getData($ResourceDescription.bean);
  }

  @override
  Future<List<ResourceDescription>> getDescriptions() async {
    await _updateAuth();
    final client = await _restClient.get();
    final result = await client.get('/api/resources');
    return await result.getList($ResourceDescription.bean);
  }

  @override
  Future<ResourceData> getResourceElement(
    String resourceId,
    String elementId, {
    String? revisionId,
  }) async {
    await _updateAuth();
    final client = await _restClient.get();
    return await client
        .get(
          '/api/resources/{resourceId}/elements/{elementId}',
          urlParams: {'resourceId': resourceId, 'elementId': elementId},
          query: {
            if (revisionId != null) 'revisionId': [revisionId],
          },
        )
        .thenGetData($ResourceData.bean);
  }

  @override
  Future<ResourceElementsResponse> getResourceElements(
    String resourceId, {
    ResourceFilter? filter,
    int offset = 0,
    int limit = 25,
  }) async {
    await _updateAuth();
    final client = await _restClient.get();
    return await client
        .get(
          '/api/resources/{resourceId}/elements',
          urlParams: {'resourceId': resourceId},
          query: {
            'offset': [offset.toString()],
            'limit': [limit.toString()],
            if (filter != null) 'filter': [jsonEncode(filter)],
          },
        )
        .thenGetData($ResourceElementsResponse.bean);
  }

  @override
  Future<ResourceData> updateElement(
    String resourceId,
    String elementId,
    Map<String, dynamic> changes,
    DateTime? revisionLive,
  ) async {
    await _updateAuth();
    final client = await _restClient.get();
    return await client
        .patch(
          '/api/resources/{resourceId}/elements/{elementId}',
          ResourceRevisionRequest(
            fieldData: changes,
            revisionLive: revisionLive,
          ),
          urlParams: {'resourceId': resourceId, 'elementId': elementId},
        )
        .thenGetData($ResourceData.bean);
  }

  @override
  Future<ResourceData?> deleteElement(
    String resourceId,
    String elementId,
    DateTime? revisionLive,
  ) async {
    await _updateAuth();
    final client = await _restClient.get();
    final response = await client.delete(
      '/api/resources/{resourceId}/elements/{elementId}',
      urlParams: {'resourceId': resourceId, 'elementId': elementId},
      query: {
        if (revisionLive != null)
          'revisionLive': [revisionLive.toIso8601String()],
      },
    );

    try {
      return await response.getData($ResourceData.bean);
    } on ApiException catch (_) {
      return null;
    }
  }
}
