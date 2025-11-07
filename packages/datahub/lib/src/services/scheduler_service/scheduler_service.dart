import 'dart:async';

import 'overlap_behaviour.dart';
import 'schedule.dart';
import 'scheduled_task.dart';

import 'package:datahub/scaffold.dart';
// TODO rework this whole concept

abstract interface class Scheduler {
  void schedule(
    Task task,
    Schedule schedule, {
    OverlapBehaviour overlap = OverlapBehaviour.concurrent,
  });
}

class SchedulerService implements Service {
  const SchedulerService();

  @override
  ServiceInstance<SchedulerService> createInstance() =>
      _SchedulerServiceInstance();
}

class _SchedulerServiceInstance extends ServiceInstance<SchedulerService>
    implements Scheduler {
  final _tasks = <ScheduledTask>[];

  @override
  void schedule(
    Task task,
    Schedule schedule, {
    OverlapBehaviour overlap = OverlapBehaviour.concurrent,
  }) {
    _tasks.add(ScheduledTask(task, _tasks.length + 1, schedule, overlap));
  }

  @override
  Future<void> dispose() async {
    for (final task in _tasks) {
      task.cancel();
    }
    await super.dispose();
  }
}
