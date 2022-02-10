import 'dart:async';

import 'package:cl_datahub/cl_datahub.dart';

typedef Task = FutureOr<void> Function();

class ScheduledTask {
  final Task task;
  final Schedule schedule;
  final OverlapBehaviour overlap;
  Timer? _timer;
  bool _running = false;

  ScheduledTask(this.task, this.schedule, this.overlap) {
    _startNext();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void _startNext([DateTime? execution]) {
    final nextExecution = _findNext(execution);
    _timer = Timer(DateTime.now().difference(nextExecution),
        () => _trigger(nextExecution));
  }

  Future<void> _trigger(execution) async {
    _timer = null;
    _startNext(execution);
    if (_running) {
      switch (overlap) {
        case OverlapBehaviour.throttle:
          return;
        case OverlapBehaviour.concurrent:
          break;
      }
    }
    _running = true;
    try {
      await task();
    } catch (e, stack) {
      resolve<LogService>().e('Scheduled execution threw exception:',
          error: e, trace: stack, sender: 'DataHub');
    } finally {
      _running = false;
    }
  }

  DateTime _findNext(DateTime? execution) {
    if (schedule is RepeatSchedule) {
      return (execution ?? DateTime.now())
          .add((schedule as RepeatSchedule).interval);
    } else if (schedule is DailySchedule) {
      if (execution != null) {
        return execution.add(const Duration(days: 1));
      } else {
        final now = DateTime.now();
        final daily = schedule as DailySchedule;
        final today = DateTime(now.year, now.month, now.day, daily.hour,
            daily.minute, daily.second);
        if (today.isAfter(now)) {
          return today;
        } else {
          return today.add(const Duration(days: 1));
        }
      }
    } else {
      throw Exception('Invalid schedule type.');
    }
  }
}
