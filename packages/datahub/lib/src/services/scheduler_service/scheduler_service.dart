import 'dart:async';

import 'package:datahub/abstract.dart';
import 'package:datahub/config.dart';
import 'package:datahub/data.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';

import 'schedule.dart';
import 'schedule_record.dart';

/// Runs [Schedule]s, provided by the built-in [SchedulerService].
abstract interface class Scheduler {
  /// Adds [schedule], for example from the `initialize` of a service. Throws
  /// an [ApiError] if a schedule with the same name was added already.
  ///
  /// Schedules in the component tree are added automatically.
  void registerSchedule(Schedule schedule);

  /// The state of all schedules (also those of other instances).
  Future<List<ScheduleRecord>> records();

  /// Runs the schedule [name] as soon as possible, in addition to its times.
  Future<void> runNow(String name);
}

/// Runs [Schedule]s exactly once per time across the instances of an
/// application. Built into `ApplicationHost` and `TestHost`, configured under
/// `scheduler`.
///
/// To provide Exactly-once-globally, the following components are required:
///
/// - a `DataRepository<ScheduleRecord>`: an instance claims a run by moving the
///   next run time of the schedule's record with a conditional update, which
///   only one instance can do,
/// - a `LockProvider<String>`, so a run never overlaps with the previous run
///   on another instance (lock `schedule:<name>`).
///
/// Without them, schedules run on every instance.
///
/// Missed runs (while no instance was running) are made up for with one run.
/// Runs are not retried, the next time runs as usual.
///
/// Spans are named `Schedule <name>`, logs and spans carry
/// `datahub.scheduler.schedule`. Metrics: `<metricPrefix>_runs_total`
/// (`schedule`, `outcome`), `<metricPrefix>_run_duration_seconds` and
/// `<metricPrefix>_lateness_seconds` (`schedule`).
class SchedulerService implements Service {
  final Find<Telemetry> telemetry;
  final Find<DataRepository<ScheduleRecord>?> recordRepository;
  final Find<LockProvider<String>?> lockProvider;

  /// Whether this instance runs schedules.
  final Config<bool> worker;

  /// Time between two checks of the schedules, for changes made by other
  /// instances. Runs themselves start at their time.
  final Config<Duration> pollInterval;

  final Config<bool> enableMetrics;
  final Config<bool> enableTracing;
  final Config<String> metricPrefix;

  const SchedulerService({
    this.telemetry = const Find(),
    this.recordRepository = const Find(),
    this.lockProvider = const Find(),
    this.worker = const Config('scheduler.worker', defaultValue: true),
    this.pollInterval = const Config(
      'scheduler.pollInterval',
      defaultValue: Duration(seconds: 10),
    ),
    this.enableMetrics = const Config(
      'scheduler.enableMetrics',
      defaultValue: true,
    ),
    this.enableTracing = const Config(
      'scheduler.enableTracing',
      defaultValue: true,
    ),
    this.metricPrefix = const Config(
      'scheduler.metricPrefix',
      defaultValue: 'scheduler',
    ),
  });

  @override
  ServiceInstance<SchedulerService> createInstance() =>
      _SchedulerServiceInstance();
}

class _SchedulerServiceInstance extends ServiceInstance<SchedulerService>
    implements Scheduler {
  static const _maxMessages = 1000;

  final _schedules = <String, Schedule>{};

  /// Schedules running on this instance, and their runs.
  final _running = <String, Future<void>>{};

  late final Zone _zone;
  late final bool _worker;
  late final Duration _pollInterval;
  late final _SchedulerTelemetry _telemetry;

  _RecordStore? _store;
  LockProvider<String>? _locks;

  Timer? _timer;
  Future<void>? _activeTick;
  bool _wakeRequested = false;
  bool _started = false;
  bool _disposed = false;

  @override
  Future<void> initialize() async {
    await super.initialize();
    _zone = Zone.current;
    _worker = read(service.worker);
    _pollInterval = read(service.pollInterval);
    _telemetry = _SchedulerTelemetry(
      find(service.telemetry),
      enableMetrics: read(service.enableMetrics),
      enableTracing: read(service.enableTracing),
      prefix: read(service.metricPrefix),
    );

    // The application components are not initialized yet (the scheduler is
    // built in), so the repository and the lock provider are found later.
    registry.registerPostInitializationCallback(() {
      _started = true;
      _wake();
    });
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    await _activeTick;
    await Future.wait(_running.values.toList());
    await super.dispose();
  }

  @override
  void registerSchedule(Schedule schedule) {
    schedule.validate();
    if (_schedules.containsKey(schedule.name)) {
      throw ApiError('There is already a schedule "${schedule.name}".');
    }
    _schedules[schedule.name] = schedule;
    _wake();
  }

  @override
  Future<List<ScheduleRecord>> records() async => await _resolve().readAll();

  @override
  Future<void> runNow(String name) async {
    final schedule =
        _schedules[name] ??
        (throw ApiRequestException.notFound('There is no schedule "$name".'));
    final store = _resolve();
    await _ensureRecord(store, schedule, DateTime.timestamp());
    await store.update(name, {
      $ScheduleRecord.$nextRunAt: DateTime.timestamp(),
    });
    _wake();
  }

  /// Finds the shared components, once.
  _RecordStore _resolve() {
    if (_store case final store?) {
      return store;
    }

    final repository = find(service.recordRepository);
    _locks = find(service.lockProvider);
    if (repository == null || _locks == null) {
      log.warn(
        'Schedules run on every instance. Add a DataRepository<ScheduleRecord> '
        'and a LockProvider<String> to run them once per time.',
      );
    }
    return _store = repository == null
        ? _MemoryRecordStore()
        : _RepositoryRecordStore(repository);
  }

  void _wake() {
    if (!_started || _disposed || !_worker || _schedules.isEmpty) {
      return;
    }

    if (_activeTick != null) {
      _wakeRequested = true;
    } else {
      _scheduleTick(Duration.zero);
    }
  }

  void _scheduleTick(Duration delay) {
    if (_disposed) {
      return;
    }

    _timer?.cancel();
    _timer = _zone.createTimer(delay, () {
      _activeTick = _tick().whenComplete(() => _activeTick = null);
    });
  }

  Future<void> _tick() async {
    DateTime? next;
    try {
      final store = _resolve();
      for (final schedule in _schedules.values.toList()) {
        if (_disposed) {
          break;
        }
        final due = await _check(store, schedule);
        if (due != null && (next == null || due.isBefore(next))) {
          next = due;
        }
      }
    } catch (error, stack) {
      log.error('Scheduler update failed.', error: error, stack: stack);
    }

    if (_disposed) {
      return;
    }

    var delay = _pollInterval.jitter(_pollInterval ~/ 10);
    if (next?.difference(DateTime.timestamp()) case final untilDue?
        when untilDue < delay) {
      delay = untilDue.isNegative ? Duration.zero : untilDue;
    }
    if (_wakeRequested) {
      delay = Duration.zero;
    }
    _wakeRequested = false;
    _scheduleTick(delay);
  }

  /// Starts a run of [schedule] if it is due. Returns when it is due next, or
  /// null if it is due but busy (it is checked again when its run ends, or
  /// with the next poll).
  Future<DateTime?> _check(_RecordStore store, Schedule schedule) async {
    final now = DateTime.timestamp();
    var record = await _ensureRecord(store, schedule, now);

    // After a change of the schedule, its next time may be earlier.
    final earliest = schedule.nextAfter(now);
    if (record.nextRunAt.isAfter(earliest)) {
      await store.moveNextRun(
        schedule.name,
        from: record.nextRunAt,
        to: earliest,
      );
      record = await store.read(schedule.name) ?? record;
    }

    if (record.nextRunAt.isAfter(now)) {
      return record.nextRunAt;
    }
    if (_running.containsKey(schedule.name)) {
      return null;
    }

    // No overlap with a run on another instance.
    final lock = await _locks?.tryAcquireLock('schedule:${schedule.name}');
    if (_locks != null && lock == null) {
      return null;
    }

    // Only one instance can move the next run time, that one runs it.
    final scheduledFor = record.nextRunAt;
    final claimed = await store.moveNextRun(
      schedule.name,
      from: scheduledFor,
      to: earliest,
    );
    if (!claimed) {
      await lock?.release();
      return null;
    }

    _start(store, schedule, scheduledFor, lock);
    return earliest;
  }

  Future<ScheduleRecord> _ensureRecord(
    _RecordStore store,
    Schedule schedule,
    DateTime now,
  ) async {
    if (await store.read(schedule.name) case final record?) {
      return record;
    }
    final record = ScheduleRecord(
      id: schedule.name,
      nextRunAt: schedule.nextAfter(now),
    );
    try {
      await store.create(record);
    } catch (_) {
      // Created by another instance in the meantime.
    }
    return await store.read(schedule.name) ?? record;
  }

  void _start(
    _RecordStore store,
    Schedule schedule,
    DateTime scheduledFor,
    LockHandle? lock,
  ) {
    _running[schedule.name] = _run(store, schedule, scheduledFor).whenComplete(
      () async {
        _running.remove(schedule.name);
        try {
          await lock?.release();
        } catch (error, stack) {
          log.error('Could not release lock.', error: error, stack: stack);
        }
        _wake();
      },
    );
  }

  Future<void> _run(
    _RecordStore store,
    Schedule schedule,
    DateTime scheduledFor,
  ) async {
    final labels = {'datahub.scheduler.schedule': schedule.name};
    final startedAt = DateTime.timestamp();
    final messages = <String>[];
    Object? failure;

    await store.update(schedule.name, {
      $ScheduleRecord.$lastScheduledFor: scheduledFor,
      $ScheduleRecord.$lastStartedAt: startedAt,
    });

    try {
      await _telemetry.trace(schedule.name, scheduledFor, () async {
        await LogListener(
          onPublish: (message) {
            if (message.level.severityNumber >
                SeverityLevel.trace.severityNumber) {
              if (messages.length >= _maxMessages) {
                messages.removeAt(0);
              }
              messages.add(message.toJsonLine());
            }
          },
        ).run(
          () => schedule
              .run(ScheduleContext(name: schedule.name, scheduledFor: scheduledFor))
              .timeout(schedule.timeout),
        );
      });
    } catch (error, stack) {
      failure = error;
      log.error(
        'Scheduled run failed.',
        error: error,
        stack: stack,
        labels: labels,
      );
    }

    final finishedAt = DateTime.timestamp();
    _telemetry.recordRun(
      schedule.name,
      succeeded: failure == null,
      duration: finishedAt.difference(startedAt),
      lateness: startedAt.difference(scheduledFor),
    );

    try {
      await store.update(schedule.name, {
        $ScheduleRecord.$lastFinishedAt: finishedAt,
        $ScheduleRecord.$lastError: failure?.toString(),
        $ScheduleRecord.$lastMessages: messages,
      });
    } catch (error, stack) {
      log.warn(
        'Could not store the result of a scheduled run.',
        error: error,
        stack: stack,
        labels: labels,
      );
    }
  }
}

/// Where the schedule records are kept: the shared repository, or memory
/// (local to this instance) if there is none.
abstract class _RecordStore {
  Future<ScheduleRecord?> read(String name);

  Future<List<ScheduleRecord>> readAll();

  Future<void> create(ScheduleRecord record);

  /// Moves the next run time of [name] from [from] to [to], if it is still
  /// [from]. Returns whether it did.
  Future<bool> moveNextRun(
    String name, {
    required DateTime from,
    required DateTime to,
  });

  Future<void> update(
    String name,
    Map<DataField<ScheduleRecord, dynamic>, dynamic> values,
  );
}

class _RepositoryRecordStore implements _RecordStore {
  final DataRepository<ScheduleRecord> repository;

  _RepositoryRecordStore(this.repository);

  @override
  Future<ScheduleRecord?> read(String name) => repository.readById(name);

  @override
  Future<List<ScheduleRecord>> readAll() => repository.readAll();

  @override
  Future<void> create(ScheduleRecord record) => repository.create(record);

  @override
  Future<bool> moveNextRun(
    String name, {
    required DateTime from,
    required DateTime to,
  }) async {
    final moved = await repository.updateAll(
      filter: Filter.andGroup([
        $ScheduleRecord.$id.equals(name),
        $ScheduleRecord.$nextRunAt.equals(from),
      ]),
      values: {$ScheduleRecord.$nextRunAt: to},
    );
    return moved == 1;
  }

  @override
  Future<void> update(
    String name,
    Map<DataField<ScheduleRecord, dynamic>, dynamic> values,
  ) => repository.updateAll(
    filter: $ScheduleRecord.$id.equals(name),
    values: values,
  );
}

class _MemoryRecordStore implements _RecordStore {
  final _records = <String, ScheduleRecord>{};

  @override
  Future<ScheduleRecord?> read(String name) async => _records[name];

  @override
  Future<List<ScheduleRecord>> readAll() async => _records.values.toList();

  @override
  Future<void> create(ScheduleRecord record) async {
    _records.putIfAbsent(record.id, () => record);
  }

  @override
  Future<bool> moveNextRun(
    String name, {
    required DateTime from,
    required DateTime to,
  }) async {
    final record = _records[name];
    if (record == null || !record.nextRunAt.isAtSameMomentAs(from)) {
      return false;
    }
    _records[name] = record.copyWith(nextRunAt: to);
    return true;
  }

  @override
  Future<void> update(
    String name,
    Map<DataField<ScheduleRecord, dynamic>, dynamic> values,
  ) async {
    final record = _records[name];
    if (record == null) {
      return;
    }
    _records[name] = $ScheduleRecord.bean.fromValues({
      for (final field in $ScheduleRecord.bean.fields)
        field.name: field.valueOf(record),
      for (final MapEntry(key: field, :value) in values.entries)
        field.name: value,
    });
  }
}

/// Spans and metrics of the scheduler.
class _SchedulerTelemetry {
  final Telemetry? _tracing;
  final CounterMetric? _runs;
  final HistogramMetric? _duration;
  final HistogramMetric? _lateness;

  _SchedulerTelemetry(
    Telemetry telemetry, {
    required bool enableMetrics,
    required bool enableTracing,
    required String prefix,
  }) : _tracing = enableTracing ? telemetry : null,
       _runs = enableMetrics
           ? telemetry.counter(
               '${prefix}_runs_total',
               labelNames: {'schedule', 'outcome'},
               help: 'Number of scheduled runs by outcome.',
             )
           : null,
       _duration = enableMetrics
           ? telemetry.histogram(
               '${prefix}_run_duration_seconds',
               buckets: HistogramMetric.defaultDurationBuckets,
               labelNames: {'schedule'},
               help: 'Time a scheduled run took.',
             )
           : null,
       _lateness = enableMetrics
           ? telemetry.histogram(
               '${prefix}_lateness_seconds',
               buckets: HistogramMetric.defaultDurationBuckets,
               labelNames: {'schedule'},
               help: 'Time between the scheduled time of a run and its start.',
             )
           : null;

  Future<void> trace(
    String name,
    DateTime scheduledFor,
    Future<void> Function() body,
  ) async {
    final telemetry = _tracing;
    if (telemetry == null) {
      return await body();
    }
    await telemetry.trace(
      'Schedule $name',
      attributes: {
        'datahub.scheduler.schedule': name,
        'datahub.scheduler.scheduled_for': scheduledFor.toIso8601String(),
      },
      (span) => body(),
    );
  }

  void recordRun(
    String name, {
    required bool succeeded,
    required Duration duration,
    required Duration lateness,
  }) {
    final labels = {'schedule': name};
    _runs?.inc({...labels, 'outcome': succeeded ? 'succeeded' : 'failed'});
    _duration?.observeDuration(duration, labels);
    _lateness?.observeDuration(
      lateness.isNegative ? Duration.zero : lateness,
      labels,
    );
  }
}
