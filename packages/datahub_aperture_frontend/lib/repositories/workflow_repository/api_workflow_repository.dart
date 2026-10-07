import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/repositories/api_repository.dart';

import 'workflow_repository.dart';

class ApiWorkflowRepository extends ApiRepository
    implements WorkflowRepository {
  ApiWorkflowRepository({required super.baseUrl});

  @override
  Future<ResourceWorkflowEventsResponse> getEvents(
    String resourceId, {
    String? elementId,
    WorkflowEventStatus? status,
    int offset = 0,
    int limit = 50,
  }) async {
    final client = await getClient();
    return await client
        .get(
          '/api/resources/{resourceId}/workflow/events',
          urlParams: {'resourceId': resourceId},
          query: {
            if (elementId != null) 'elementId': [elementId],
            if (status != null)
              'status': [const JsonDataCodec().encodeEnum(status)],
            'offset': [offset.toString()],
            'limit': [limit.toString()],
          },
        )
        .thenGetData($ResourceWorkflowEventsResponse.bean);
  }

  @override
  Future<List<WorkflowHistoryEntry>> getHistory(
    String resourceId,
    String elementId, {
    int offset = 0,
    int limit = 25,
  }) async {
    final client = await getClient();
    final result = await client.get(
      '/api/resources/{resourceId}/elements/{elementId}/workflow/history',
      urlParams: {'resourceId': resourceId, 'elementId': elementId},
      query: {
        'offset': [offset.toString()],
        'limit': [limit.toString()],
      },
    );
    return await result.getList($WorkflowHistoryEntry.bean);
  }

  @override
  Future<void> sendSignal(
    String resourceId,
    String elementId,
    String signalId,
    Map<String, dynamic> payload,
  ) async {
    const codec = JsonDataCodec();
    final client = await getClient();
    await client.post(
      '/api/resources/{resourceId}/elements/{elementId}/workflow/signals/{signalId}',
      codec.encodeMap(payload, codec.encodeDynamic),
      urlParams: {
        'resourceId': resourceId,
        'elementId': elementId,
        'signalId': signalId,
      },
    );
  }

  @override
  Future<void> retryEvent(String resourceId, String eventId) async {
    final client = await getClient();
    await client.post(
      '/api/resources/{resourceId}/workflow/events/{eventId}/retry',
      null,
      urlParams: {'resourceId': resourceId, 'eventId': eventId},
    );
  }

  @override
  Future<void> cancelEvent(String resourceId, String eventId) async {
    final client = await getClient();
    await client.delete(
      '/api/resources/{resourceId}/workflow/events/{eventId}',
      urlParams: {'resourceId': resourceId, 'eventId': eventId},
    );
  }

  @override
  Future<void> resume(String resourceId, String elementId) async {
    final client = await getClient();
    await client.post(
      '/api/resources/{resourceId}/elements/{elementId}/workflow/resume',
      null,
      urlParams: {'resourceId': resourceId, 'elementId': elementId},
    );
  }
}
