import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/modules.dart';
import 'package:datahub_aperture_frontend/repositories/api_repository.dart';

import 'task_manager_repository.dart';

class ApiTaskManagerRepository extends ApiRepository
    implements TaskManagerRepository {
  static const moduleId = 'task-manager';

  ApiTaskManagerRepository({required super.baseUrl});

  @override
  Future<void> cancelInvocation(String invocationId) async {
    // TODO: implement cancelInvocation
    throw UnimplementedError();
  }

  @override
  Future<List<TaskInvocation>> getInvocations({String? taskId}) async {
    final client = await getClient();
    return await client
        .get(
          '/api/modules/{moduleId}/invocations',
          urlParams: {'moduleId': moduleId},
        )
        .thenGetList($TaskInvocation.bean);
  }

  @override
  Future<List<TaskDescription>> getDescriptions() async {
    final client = await getClient();
    return await client
        .get('/api/modules/{moduleId}', urlParams: {'moduleId': moduleId})
        .thenGetList($TaskDescription.bean);
  }

  @override
  Future<TaskInvocation> getInvocation(String invocationId) async {
    final client = await getClient();
    return await client
        .get(
          '/api/modules/{moduleId}/invocations/{invocationId}',
          urlParams: {'moduleId': moduleId, 'invocationId': invocationId},
        )
        .thenGetData($TaskInvocation.bean);
  }
}
