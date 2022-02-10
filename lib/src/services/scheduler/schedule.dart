//TODO more sophisticated scheduling...
/// Defines the schedule for task execution in [SchedulerService].
abstract class Schedule {
  const Schedule();

  factory Schedule.repeat(Duration interval) => RepeatSchedule(interval);

  factory Schedule.daily(int hour, [int minute = 0, int second = 0]) =>
      DailySchedule(hour, minute, second);
}

/// Repeated execution with interval [Duration].
class RepeatSchedule extends Schedule {
  final Duration interval;

  const RepeatSchedule(this.interval);
}

class DailySchedule extends Schedule {
  final int hour;
  final int minute;
  final int second;

  DailySchedule(this.hour, [this.minute = 0, this.second = 0]);
}
