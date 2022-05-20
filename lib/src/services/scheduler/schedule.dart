//TODO more sophisticated scheduling...
/// Defines the schedule for task execution in [SchedulerService].
abstract class Schedule {
  const Schedule();

  factory Schedule.repeat(Duration interval, {bool startNow = true}) =>
      RepeatSchedule(interval, startNow);

  factory Schedule.daily(int hour, [int minute = 0, int second = 0]) =>
      DailySchedule(hour, minute, second);

  DateTime findNext(DateTime? lastExecution);
}

/// Repeated execution with interval [Duration].
class RepeatSchedule extends Schedule {
  final Duration interval;
  final bool startNow;

  const RepeatSchedule(this.interval, this.startNow);

  @override
  DateTime findNext(DateTime? execution) {
    if (execution == null && startNow) {
      return DateTime.now();
    }

    return (execution ?? DateTime.now()).add(interval);
  }
}

class DailySchedule extends Schedule {
  final int hour;
  final int minute;
  final int second;

  DailySchedule(this.hour, [this.minute = 0, this.second = 0]);

  @override
  DateTime findNext(DateTime? execution) {
    if (execution != null) {
      return execution.add(const Duration(days: 1));
    } else {
      final now = DateTime.now();
      final today =
          DateTime(now.year, now.month, now.day, hour, minute, second);
      if (today.isAfter(now)) {
        return today;
      } else {
        return today.add(const Duration(days: 1));
      }
    }
  }
}
