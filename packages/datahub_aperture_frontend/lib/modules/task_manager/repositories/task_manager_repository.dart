import 'package:datahub/datahub.dart';

import 'package:datahub_aperture/modules.dart';

abstract interface class TaskManagerRepository {
  Future<List<TaskDescription>> getDescriptions();
  Future<List<TaskInvocation>> getInvocations({String? taskId});
  Future<TaskInvocation> getInvocation(String invocationId);

  Future<void> cancelInvocation(String invocationId);
}