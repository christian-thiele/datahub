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
    final nextExecution = schedule.findNext(execution);
    _timer = Timer(nextExecution.difference(DateTime.now()),
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
}
