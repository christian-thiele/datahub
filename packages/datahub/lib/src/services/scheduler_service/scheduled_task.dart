import 'dart:async';

import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';

import 'overlap_behaviour.dart';
import 'schedule.dart';

typedef Task = FutureOr<void> Function();

class ScheduledTask {
  final int taskId;
  final Task task;
  final Schedule schedule;
  final OverlapBehaviour overlap;
  Timer? _timer;
  bool _running = false;

  ScheduledTask(this.task, this.taskId, this.schedule, this.overlap) {
    _startNext();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void _startNext([DateTime? execution]) {
    final nextExecution = schedule.findNext(execution);
    _timer = Timer(
      nextExecution.difference(DateTime.now()),
      () => _trigger(nextExecution),
    );
  }

  Future<void> _trigger(DateTime execution) async {
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
    unawaited(
      runZonedGuarded(
        () async {
          try {
            await task();
          } finally {
            _running = false;
          }
        },
        (error, stack) {
          log.error(
            'Scheduled execution threw exception:',
            error: error,
            stack: stack,
          );
        },
        zoneValues: {
          #schedulerExecutionId:
              'ST:${taskId.toString().padLeft(2, '0')}:${randomHexId(2)}',
        },
      ),
    );
  }
}
