import 'dart:async';
import 'dart:math' as math;

import 'package:boost/boost.dart';
import 'package:datahub/data.dart';
import 'package:datahub/config.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';

import 'task_invocation.dart';

interface class TaskProgress {
  final void Function(double progress) reportProgress;

  final void Function(dynamic error, [StackTrace? trace]) reportError;

  TaskProgress._({required this.reportProgress, required this.reportError});

  TaskProgress subProgress(double from, double length) {
    return TaskProgress._(
      reportProgress: (p) => reportProgress(
        math.max(from, math.min(from + length, from + length * p)),
      ),
      reportError: reportError,
    );
  }
}

interface class TaskHandle<T> {
  final Future<String> Function(T params, {DateTime? schedule})
  scheduleInvocation;

  TaskHandle._({required this.scheduleInvocation});
}

typedef TaskDelegate<T> =
    Future<void> Function(TaskProgress progress, T params);

class TaskExecutor<T extends DataObject> {
  final String taskId;
  final String? displayName;
  final DataBean<T> bean;
  final TaskHandle<T> handle;
  final TaskDelegate<T> delegate;

  TaskExecutor({
    required this.taskId,
    required this.displayName,
    required this.bean,
    required this.handle,
    required this.delegate,
  });

  Future<void> execute(TaskProgress progress, DataObject params) async {
    if (params is T) {
      await delegate(progress, params);
    } else {
      throw ApiException('Invalid parameter type for TaskExecutor.');
    }
  }
}

abstract interface class TaskManager {
  List<TaskExecutor> getRegisteredExecutors();

  Future<TaskHandle<T>> registerExecutor<T extends DataObject>(
    String taskId,
    DataBean<T> bean,
    TaskDelegate<T> delegate,
  );

  Future<List<TaskInvocation>> getInvocations({
    Filter filter = Filter.empty,
    int offset = 0,
    int limit = -1,
  });

  Future<void> cancelInvocation(String invocationId);
}

class TaskManagerService implements Service {
  final Find<Telemetry> telemetry;
  final Find<DataRepository<TaskInvocation>> taskInvocationRepository;
  final Config<Duration> heartbeatTimeout;
  final Config<Duration> heartbeatInterval;

  const TaskManagerService({
    this.telemetry = const Find(),
    this.taskInvocationRepository = const Find(),
    this.heartbeatInterval = const Config(
      'taskManager.heartbeatInterval',
      defaultValue: Duration(seconds: 10),
    ),
    this.heartbeatTimeout = const Config(
      'taskManager.heartbeatTimeout',
      defaultValue: Duration(minutes: 1),
    ),
  });

  @override
  ServiceInstance<Service> createInstance() => _TaskManagerServiceInstance();
}

class _TaskManagerServiceInstance extends ServiceInstance<TaskManagerService>
    implements TaskManager {
  final _executors = <String, TaskExecutor>{};
  late final Telemetry telemetry;
  late final DataRepository<TaskInvocation> taskInvocationRepository;
  Timer? _timer;
  final _semaphore = Semaphore();

  @override
  Future<void> initialize() async {
    await super.initialize();
    telemetry = find(service.telemetry);
    taskInvocationRepository = find(service.taskInvocationRepository);
    await _updateTimeoutTasks();
    await _updateTimer();
  }

  @override
  Future<void> dispose() async {
    log.debug('Shutting down TaskManager.');
    _timer?.cancel();
    if (_semaphore.isLocked) {
      log.debug('TaskManager locked, waiting for running tasks.');
    }

    await _semaphore.lock();
    await super.dispose();
  }

  void _setNextUpdateTimestamp(DateTime timestamp) {
    _timer?.cancel();
    _timer = Timer(timestamp.difference(DateTime.timestamp()), _update);
  }

  TaskExecutor _findExecutorForInvocation(TaskInvocation invocation) {
    return _executors[invocation.taskId] ??
        (throw ApiException(
          'No executor registered for taskId "${invocation.taskId}".',
        ));
  }

  Future<void> _update() async {
    log.debug('TaskManager update triggered.');
    if (_semaphore.isLocked) {
      log.debug('TaskManager busy, canceling update.');
      return;
    }

    await _semaphore.runLocked(() async {
      try {
        await _updateTimeoutTasks();
        await _runNextTask();
      } catch (error, stack) {
        log.error('TaskManager update failed.', error: error, stack: stack);
      } finally {
        await _updateTimer();
      }
    });
    log.debug('TaskManager lock released.');
  }

  Future<void> _updateTimer() async {
    final random = math.Random();
    final jitter = Duration(milliseconds: random.nextInt(3000) - 1500);
    const updateInterval = Duration(minutes: 5);
    final latestNextUpdate = DateTime.timestamp()
        .add(updateInterval)
        .add(jitter);
    final nextInvocation = await _findNextInvocationTimestamp();
    final nextUpdate =
        (nextInvocation != null && nextInvocation.isBefore(latestNextUpdate))
        ? nextInvocation
        : latestNextUpdate;
    _setNextUpdateTimestamp(nextUpdate);
  }

  Future<void> _updateTimeoutTasks() async {
    final heartbeatTimeout = read(service.heartbeatTimeout);
    await taskInvocationRepository.updateAll(
      filter: Filter.andGroup([
        $TaskInvocation.$state.equals(TaskState.running),
        Filter.orGroup([
          Filter.andGroup([
            $TaskInvocation.$lastHeartbeat.equals(null),
            $TaskInvocation.$startedAt.lessThan(
              DateTime.timestamp().subtract(heartbeatTimeout),
            ),
          ]),
          $TaskInvocation.$lastHeartbeat.lessThan(
            DateTime.timestamp().subtract(heartbeatTimeout),
          ),
        ]),
      ]),
      values: {
        $TaskInvocation.$state: TaskState.timeout,
        $TaskInvocation.$finishedAt: DateTime.timestamp(),
      },
    );
  }

  Future<void> _runNextTask() async {
    // TODO for-update
    final invocation = await taskInvocationRepository.atomic(() async {
      final result = await taskInvocationRepository.readAll(
        filter: Filter.andGroup([
          $TaskInvocation.$state.equals(TaskState.scheduled),
          $TaskInvocation.$scheduledFor.lessOrEqual(DateTime.timestamp()),
        ]),
        limit: 1,
        sort: $TaskInvocation.$scheduledFor.asc(),
      );

      if (result.firstOrNull case final pending?) {
        final invocation = pending.copyWith(
          state: TaskState.running,
          startedAt: DateTime.timestamp(),
        );
        await taskInvocationRepository.updateById(invocation);
        return invocation;
      }
    });

    if (invocation != null) {
      log.info('Task ${invocation.taskId}/${invocation.id} started.');
      try {
        final progressSemaphore = Semaphore();
        final progress = TaskProgress._(
          reportProgress: (progress) {
            log(
              'Task ${invocation.taskId}/${invocation.id}: ${(math.min(math.max(0, progress), 1) * 100).toInt()}%',
            );
            progressSemaphore.throttle(() async {
              final heartbeatAt = DateTime.timestamp();
              await taskInvocationRepository.updateAll(
                filter: Filter.andGroup([
                  $TaskInvocation.$id.equals(invocation.id),
                  Filter.orGroup([
                    $TaskInvocation.$lastHeartbeat.equals(null),
                    $TaskInvocation.$lastHeartbeat.lessThan(heartbeatAt),
                  ]),
                ]),
                values: {
                  $TaskInvocation.$progress: progress,
                  $TaskInvocation.$lastHeartbeat: heartbeatAt,
                },
              );
            });
          },
          reportError: (error, [stack]) {
            log.error(
              'Error in Task ${invocation.taskId}/${invocation.id}',
              error: error,
              stack: stack,
            );
          },
        );
        final executor = _findExecutorForInvocation(invocation);
        final parameters = executor.bean.fromJson(invocation.parameters);
        await telemetry.trace(
          'Task ${executor.displayName ?? executor.taskId}',
          (span) async => await executor.execute(progress, parameters),
          attributes: {
            'datahub.task.id': executor.taskId,
            'datahub.task.invocation_id': invocation.id,
          },
        );
        final finishedAt = DateTime.timestamp();
        await taskInvocationRepository.updateById(
          invocation.copyWith(
            state: TaskState.finished,
            finishedAt: finishedAt,
            lastHeartbeat: finishedAt,
            progress: 1.0,
          ),
        );
      } catch (error, stack) {
        log.error(
          'Error while executing task ${invocation.taskId}/${invocation.id}.',
          error: error,
          stack: stack,
        );

        await taskInvocationRepository.updateById(
          invocation.copyWith(
            finishedAt: DateTime.timestamp(),
            state: TaskState.failed,
          ),
        );
      }
    }
  }

  Future<DateTime?> _findNextInvocationTimestamp() async {
    try {
      final nextInvocation = await taskInvocationRepository.readAll(
        filter: Filter.andGroup([
          $TaskInvocation.$state.equals(TaskState.scheduled),
        ]),
        sort: $TaskInvocation.$scheduledFor.asc(),
      );

      return nextInvocation.firstOrNull?.scheduledFor;
    } catch (e, stack) {
      log.error(
        'Could not read next invocation timestamp for TaskManager.',
        error: e,
        stack: stack,
      );
      return null;
    }
  }

  @override
  List<TaskExecutor> getRegisteredExecutors() {
    return _executors.values.toList();
  }

  @override
  Future<TaskHandle<T>> registerExecutor<T extends DataObject>(
    String taskId,
    DataBean<T> bean,
    TaskDelegate<T> delegate, {
    String? displayName,
  }) async {
    final handle = TaskHandle<T>._(
      scheduleInvocation: (params, {schedule}) =>
          enqueueInvocation(taskId, params, schedule: schedule),
    );

    _executors[taskId] = TaskExecutor<T>(
      taskId: taskId,
      bean: bean,
      handle: handle,
      delegate: delegate,
      displayName: displayName,
    );

    return handle;
  }

  @override
  Future<void> cancelInvocation(String invocationId) async {
    await taskInvocationRepository.atomic(() async {
      final invocation = await taskInvocationRepository.readById(invocationId);
      if (invocation == null) {
        throw ApiRequestException.notFound('TaskInvocation not found.');
      }

      switch (invocation.state) {
        case TaskState.scheduled:
          await taskInvocationRepository.updateById(
            invocation.copyWith(state: TaskState.canceled),
          );
        case TaskState.running:
        // TODO implement running
        case TaskState.finished:
        case TaskState.failed:
        case TaskState.timeout:
        case TaskState.canceled:
          throw ApiRequestException.badRequest(
            'TaskInvocation already ${invocation.state.name}.',
          );
      }
    });
  }

  Future<String> enqueueInvocation(
    String taskId,
    DataObject params, {
    DateTime? schedule,
  }) async {
    final now = DateTime.timestamp();
    final invocation = await taskInvocationRepository.create(
      TaskInvocation(
        id: '',
        taskId: taskId,
        state: TaskState.scheduled,
        parameters: params.toJson(),
        scheduledAt: now,
        scheduledFor: schedule ?? now,
        lastHeartbeat: null,
        progress: 0.0,
        startedAt: null,
        finishedAt: null,
      ),
    );

    await _updateTimer();

    return invocation.id;
  }

  @override
  Future<List<TaskInvocation>> getInvocations({
    Filter filter = Filter.empty,
    int offset = 0,
    int limit = -1,
  }) async {
    return await taskInvocationRepository.readAll(
      filter: filter,
      offset: offset,
      sort: $TaskInvocation.$scheduledFor.desc(),
      limit: limit,
    );
  }
}
