import 'dart:math' as math;

import 'package:datahub/scaffold.dart';
import 'package:datahub/utils.dart';

import 'scheduler_service.dart';

/// What a scheduled callback knows about its run.
class ScheduleContext {
  /// The name of the schedule.
  final String name;

  /// The time the run was scheduled for (UTC).
  ///
  /// Runs that were missed while no instance was running are made up for with
  /// a single, late run; this is the latest missed time then.
  final DateTime scheduledFor;

  const ScheduleContext({required this.name, required this.scheduledFor});

  /// Identifies the run, for calls that must not be repeated.
  String get idempotencyKey => '$name/${scheduledFor.toIso8601String()}';
}

typedef ScheduleCallback = Future<void> Function(ScheduleContext run);

/// Runs [run] repeatedly at fixed times (UTC), exactly once per time across
/// all instances of an application (see [SchedulerService]).
///
/// A schedule is a component: add it to the components of the application
/// (or of a test), or register it at runtime with [Scheduler.registerSchedule].
///
/// ```dart
/// runApp([
///   ...,
///   Schedule.every('fetch-rates', fetchRates,
///       interval: Duration(minutes: 10)),
///   Schedule.daily('cleanup', cleanup, hour: 3),
///   Schedule.monthly('billing', startBilling, day: 1),
/// ]);
/// ```
abstract class Schedule implements Service {
  /// Identifies the schedule across instances, must be unique.
  final String name;

  final ScheduleCallback run;

  /// Maximum time a run may take. A run that is due while the previous run
  /// still runs waits for it.
  final Duration timeout;

  const Schedule._(this.name, this.run, {required this.timeout});

  /// Runs every [interval]. The times are aligned to the epoch (for example
  /// every 10 minutes at :00, :10, :20 ...), so all instances agree on them.
  const factory Schedule.every(
    String name,
    ScheduleCallback run, {
    required Duration interval,
    Duration timeout,
  }) = _EverySchedule;

  /// Runs every day at [hour]:[minute] UTC.
  const factory Schedule.daily(
    String name,
    ScheduleCallback run, {
    int hour,
    int minute,
    Duration timeout,
  }) = _DailySchedule;

  /// Runs every month on [day] at [hour]:[minute] UTC. Days after the end of
  /// a month mean its last day.
  const factory Schedule.monthly(
    String name,
    ScheduleCallback run, {
    int day,
    int hour,
    int minute,
    Duration timeout,
  }) = _MonthlySchedule;

  /// The first time after [time] the schedule runs at.
  DateTime nextAfter(DateTime time);

  /// Throws an [ApiError] if the schedule is declared inconsistently.
  void validate() {
    if (name.isEmpty) {
      throw ApiError('A schedule needs a name.');
    }
  }

  @override
  ServiceInstance<Schedule> createInstance() => _ScheduleInstance();
}

class _ScheduleInstance extends ServiceInstance<Schedule> {
  @override
  Future<void> initialize() async {
    await super.initialize();
    find(const Find<Scheduler>()).registerSchedule(service);
  }
}

const _defaultTimeout = Duration(minutes: 30);

final class _EverySchedule extends Schedule {
  final Duration interval;

  const _EverySchedule(
    super.name,
    super.run, {
    required this.interval,
    super.timeout = _defaultTimeout,
  }) : super._();

  @override
  DateTime nextAfter(DateTime time) {
    final step = interval.inMicroseconds;
    final now = time.toUtc().microsecondsSinceEpoch;
    return DateTime.fromMicrosecondsSinceEpoch(
      (now ~/ step + 1) * step,
      isUtc: true,
    );
  }

  @override
  void validate() {
    super.validate();
    if (interval <= Duration.zero) {
      throw ApiError('Schedule "$name" needs a positive interval.');
    }
  }
}

final class _DailySchedule extends Schedule {
  final int hour;
  final int minute;

  const _DailySchedule(
    super.name,
    super.run, {
    this.hour = 0,
    this.minute = 0,
    super.timeout = _defaultTimeout,
  }) : super._();

  @override
  DateTime nextAfter(DateTime time) {
    final utc = time.toUtc();
    final today = DateTime.utc(utc.year, utc.month, utc.day, hour, minute);
    return today.isAfter(utc)
        ? today
        : DateTime.utc(utc.year, utc.month, utc.day + 1, hour, minute);
  }

  @override
  void validate() {
    super.validate();
    _validateTime(name, hour, minute);
  }
}

final class _MonthlySchedule extends Schedule {
  final int day;
  final int hour;
  final int minute;

  const _MonthlySchedule(
    super.name,
    super.run, {
    this.day = 1,
    this.hour = 0,
    this.minute = 0,
    super.timeout = _defaultTimeout,
  }) : super._();

  @override
  DateTime nextAfter(DateTime time) {
    final utc = time.toUtc();
    final thisMonth = _inMonth(utc.year, utc.month);
    return thisMonth.isAfter(utc)
        ? thisMonth
        : _inMonth(utc.year, utc.month + 1);
  }

  /// The run time in [month] of [year] (months after 12 continue next year).
  DateTime _inMonth(int year, int month) {
    final lastDay = DateTime.utc(year, month + 1, 0).day;
    return DateTime.utc(year, month, math.min(day, lastDay), hour, minute);
  }

  @override
  void validate() {
    super.validate();
    if (day < 1 || day > 31) {
      throw ApiError('Schedule "$name" needs a day between 1 and 31.');
    }
    _validateTime(name, hour, minute);
  }
}

void _validateTime(String name, int hour, int minute) {
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    throw ApiError('Schedule "$name" has an invalid time $hour:$minute.');
  }
}
