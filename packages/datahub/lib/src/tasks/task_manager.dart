import 'dart:async';
import 'dart:math' as math;

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/data.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';

import 'task_invocation.dart';

interface class TaskProgress {
  final void Function(double progress) reportProgress;

  final void Function(dynamic error, [StackTrace? trace]) reportError;

  TaskProgress._({required this.reportProgress, required this.reportError});
}

interface class TaskHandle<T> {
  final Future<void> Function(T params, {DateTime? schedule})
  scheduleInvocation;

  TaskHandle._({required this.scheduleInvocation});
}

typedef TaskDelegate<T> =
    Future<void> Function(TaskProgress progress, T params);

class TaskExecutor<T extends DataObject> {
  final String taskId;
  final DataBean<T> bean;
  final TaskDelegate<T> delegate;

  TaskExecutor({
    required this.taskId,
    required this.bean,
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
  List<String> getRegisteredTaskIds();

  Future<TaskHandle<T>> registerExecutor<T extends DataObject>(
    String taskId,
    DataBean<T> bean,
    TaskDelegate<T> delegate,
  );
}

class TaskManagerService implements Service {
  final Find<DataRepository<TaskInvocation>> taskInvocationRepository;

  TaskManagerService({this.taskInvocationRepository = const Find()});

  @override
  ServiceInstance<Service> createInstance() => _TaskManagerServiceInstance();
}

class _TaskManagerServiceInstance extends ServiceInstance<TaskManagerService>
    implements TaskManager {
  final _executors = <String, TaskExecutor>{};
  late final DataRepository<TaskInvocation> taskInvocationRepository;
  DateTime? _nextUpdateTimestamp;
  Timer? _timer;
  final _semaphore = Semaphore();

  @override
  Future<void> initialize() async {
    await super.initialize();
    taskInvocationRepository = find(service.taskInvocationRepository);
    if (await _findNextInvocationTimestamp() case final timestamp?) {
      _setNextUpdateTimestamp(timestamp);
    }
  }

  @override
  Future<void> dispose() async {
    log.debug('Shutting down TaskManager.');
    if (_semaphore.isLocked) {
      log.debug('TaskManager locked, waiting for running tasks.');
    }

    await _semaphore.lock();
    await super.dispose();
  }

  void _setNextUpdateTimestamp(DateTime timestamp) {
    _timer?.cancel();
    _nextUpdateTimestamp = timestamp;
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
    _nextUpdateTimestamp = null;
    if (_semaphore.isLocked) {
      log.debug('TaskManager busy, canceling update.');
      return;
    }

    await _semaphore.runLocked(() async {
      try {
        await _runNextTask();
        if (await _findNextInvocationTimestamp() case final timestamp?) {
          _setNextUpdateTimestamp(timestamp);
        }
      } catch (error, stack) {
        log.error('TaskManager update failed.', error: error, stack: stack);
      }
    });
    log.debug('TaskManager lock released.');
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
        final progress = TaskProgress._(
          reportProgress: (progress) {
            log(
              'Task ${invocation.taskId}/${invocation.id}: ${(math.min(math.max(0, progress), 1) * 100).toInt()}%',
            );
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
        await executor.execute(progress, parameters);
        progress.reportProgress(1);
        await taskInvocationRepository.updateById(
          invocation.copyWith(
            finishedAt: DateTime.timestamp(),
            state: TaskState.finished,
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
    final nextInvocation = await taskInvocationRepository.readAll(
      filter: Filter.andGroup([
        $TaskInvocation.$state.equals(TaskState.scheduled),
      ]),
      sort: $TaskInvocation.$scheduledFor.asc(),
    );

    return nextInvocation.firstOrNull?.scheduledFor;
  }

  @override
  List<String> getRegisteredTaskIds() {
    return _executors.keys.toList();
  }

  @override
  Future<TaskHandle<T>> registerExecutor<T extends DataObject>(
    String taskId,
    DataBean<T> bean,
    TaskDelegate<T> delegate,
  ) async {
    _executors[taskId] = TaskExecutor<T>(
      taskId: taskId,
      bean: bean,
      delegate: delegate,
    );

    return TaskHandle<T>._(
      scheduleInvocation: (params, {schedule}) =>
          enqueueInvocation(taskId, params, schedule: schedule),
    );
  }

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
        case TaskState.canceled:
          throw ApiRequestException.badRequest(
            'TaskInvocation already ${invocation.state.name}.',
          );
      }
    });
  }

  Future<void> enqueueInvocation(
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
        startedAt: null,
        finishedAt: null,
      ),
    );

    if (_nextUpdateTimestamp?.isBefore(invocation.scheduledFor) ?? true) {
      _setNextUpdateTimestamp(invocation.scheduledFor);
    }
  }
}
