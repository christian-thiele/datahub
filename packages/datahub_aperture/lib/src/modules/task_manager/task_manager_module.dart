import 'dart:math' as math;

import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/services.dart';
import 'package:datahub_aperture/utils.dart';

import 'api/task_description.dart';

class TaskManagerModule implements ApertureModule {
  final String id;
  final String displayName;
  final int icon;
  final ModuleType type = ModuleType.taskManager;

  final Find<TaskManager> taskManager;

  const TaskManagerModule({
    this.id = 'task-manager',
    this.taskManager = const Find<TaskManager>(),
    this.displayName = 'Task Manager',
    this.icon = Icons.task,
  });

  @override
  ModuleDescription get description => ModuleDescription(
        id: id,
        displayName: displayName,
        icon: icon,
        type: type,
        configuration: {},
      );

  @override
  List<ApiRoute> buildApiRoutes(String base) {
    return [
      ResourceEndpoint(
        matcher: RoutePattern(base),
        get: (request) async {
          final taskManager = Find<TaskManager?>().find() ??
              (throw ApiRequestException.notFound());

          final executors = taskManager.getRegisteredExecutors();
          return [
            for (final executor in executors)
              TaskDescription(
                id: executor.taskId,
                displayName: executor.displayName ?? niceName(executor.taskId),
                icon: icon,
              ),
          ];
        },
      ),
      ResourceEndpoint(
        matcher: RoutePattern('$base/invocations'),
        get: (request) async {
          final taskManager = Find<TaskManager?>().find() ??
              (throw ApiRequestException.notFound());
          final offset = request.getParam<int?>('offset') ?? 0;
          final limit = math.min(100, request.getParam<int?>('limit') ?? 50);
          final taskId = request.getParam<String?>('taskId');
          return await taskManager.getInvocations(
            filter: switch (taskId) {
              String() => $TaskInvocation.$taskId.equals(taskId),
              _ => Filter.empty,
            },
            offset: offset,
            limit: limit,
          );
        },
      ),
    ];
  }
}
