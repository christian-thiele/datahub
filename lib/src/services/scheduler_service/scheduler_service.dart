import 'dart:async';

import 'package:datahub/ioc.dart';

import 'overlap_behaviour.dart';
import 'schedule.dart';
import 'scheduled_task.dart';

/// Provides a pattern for creating scheduled execution of tasks.
class SchedulerService extends BaseService {
  final _tasks = <ScheduledTask>[];

  //TODO possibility to cancel task
  void schedule(Task task, Schedule schedule,
      {OverlapBehaviour overlap = OverlapBehaviour.concurrent}) {
    _tasks.add(ScheduledTask(task, schedule, overlap));
  }

  @override
  Future<void> shutdown() async {
    _tasks.forEach((task) => task.cancel());
  }
}
