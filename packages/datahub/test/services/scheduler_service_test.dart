import 'dart:async';
import 'dart:convert';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

/// Runs by schedule name.
final _runs = <String, List<ScheduleContext>>{};

Future<void> _record(ScheduleContext run) async =>
    _runs.putIfAbsent(run.name, () => []).add(run);

List<ScheduleContext> _runsOf(String name) => _runs[name] ?? const [];

DataRepository<ScheduleRecord> get _records =>
    Find<DataRepository<ScheduleRecord>>().find();

/// Shared components, so schedules run once per time across instances.
List<Component> _shared({List<ScheduleRecord> records = const []}) => [
  MemoryRepositoryService(bean: $ScheduleRecord.bean, initialData: records),
  const MemoryLockService<String>(),
];

/// An instance of the application with its own scheduler (instead of the
/// built-in one) and [schedules].
Component _instance(
  int index,
  List<Schedule> schedules, {
  bool worker = true,
}) => Scope(
  name: 'instance-$index',
  components: [
    SchedulerService(
      pollInterval: Config.value(const Duration(milliseconds: 50)),
      worker: Config.value(worker),
    ),
    ...schedules,
  ],
);

Future<void> _eventually(
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  String reason = 'condition',
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!await condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out after $timeout waiting for $reason.');
    }
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  setUp(_runs.clear);

  group('Schedule.nextAfter', () {
    Future<void> noop(ScheduleContext run) async {}

    test('aligns intervals to the epoch', () {
      final schedule = Schedule.every(
        'a',
        noop,
        interval: const Duration(minutes: 10),
      );
      expect(
        schedule.nextAfter(DateTime.utc(2026, 1, 1, 12, 3, 30)),
        DateTime.utc(2026, 1, 1, 12, 10),
      );
      expect(
        schedule.nextAfter(DateTime.utc(2026, 1, 1, 12, 10)),
        DateTime.utc(2026, 1, 1, 12, 20),
      );
    });

    test('runs daily at the given time', () {
      final schedule = Schedule.daily('a', noop, hour: 3, minute: 30);
      expect(
        schedule.nextAfter(DateTime.utc(2026, 1, 1, 1)),
        DateTime.utc(2026, 1, 1, 3, 30),
      );
      expect(
        schedule.nextAfter(DateTime.utc(2026, 1, 1, 3, 30)),
        DateTime.utc(2026, 1, 2, 3, 30),
      );
      expect(
        schedule.nextAfter(DateTime.utc(2026, 12, 31, 4)),
        DateTime.utc(2027, 1, 1, 3, 30),
      );
    });

    test('runs monthly, on the last day of short months', () {
      final first = Schedule.monthly('a', noop);
      expect(
        first.nextAfter(DateTime.utc(2026, 11, 15)),
        DateTime.utc(2026, 12, 1),
      );
      expect(
        first.nextAfter(DateTime.utc(2026, 12, 1)),
        DateTime.utc(2027, 1, 1),
      );

      final last = Schedule.monthly('b', noop, day: 31);
      expect(
        last.nextAfter(DateTime.utc(2026, 2, 1)),
        DateTime.utc(2026, 2, 28),
      );
      expect(
        last.nextAfter(DateTime.utc(2028, 2, 1)),
        DateTime.utc(2028, 2, 29),
      );
      expect(
        last.nextAfter(DateTime.utc(2026, 2, 28)),
        DateTime.utc(2026, 3, 31),
      );
    });

    test('rejects invalid schedules', () {
      expect(
        // ignore: datahub_lints/schedule_requires_positive_interval
        () => Schedule.every('a', noop, interval: Duration.zero).validate(),
        throwsA(isA<ApiError>()),
      );
      expect(
        // ignore: datahub_lints/schedule_time_out_of_range
        () => Schedule.daily('a', noop, hour: 24).validate(),
        throwsA(isA<ApiError>()),
      );
      expect(
        // ignore: datahub_lints/schedule_time_out_of_range
        () => Schedule.monthly('a', noop, day: 0).validate(),
        throwsA(isA<ApiError>()),
      );
    });
  });

  declareTest(
    'runs a schedule from the components at its times',
    [
      Schedule.every(
        'tick',
        _record,
        interval: const Duration(milliseconds: 100),
      ),
    ],
    () async {
      await _eventually(() => _runsOf('tick').length >= 3, reason: '3 runs');

      final times = _runsOf('tick').map((r) => r.scheduledFor).toList();
      for (final time in times) {
        expect(time.microsecondsSinceEpoch % 100000, 0, reason: 'aligned');
      }
      expect(times.toSet(), hasLength(times.length));
    },
  );

  declareTest(
    'registers schedules from other services',
    [
      ServiceDelegate(
        initialize: () async {
          final scheduler = Find<Scheduler>().find();
          final schedule = Schedule.every(
            'registered',
            _record,
            interval: const Duration(milliseconds: 100),
          );
          scheduler.registerSchedule(schedule);
          expect(
            () => scheduler.registerSchedule(schedule),
            throwsA(isA<ApiError>()),
          );
        },
      ),
    ],
    () async {
      await _eventually(
        () => _runsOf('registered').isNotEmpty,
        reason: 'a run',
      );
    },
  );

  declareTest(
    'runs each time once with multiple instances',
    [
      ..._shared(),
      for (var i = 0; i < 3; i++)
        _instance(i, [
          Schedule.every(
            'shared',
            _record,
            interval: const Duration(milliseconds: 150),
          ),
        ]),
    ],
    () async {
      await _eventually(() => _runsOf('shared').length >= 5, reason: '5 runs');

      final times = _runsOf('shared').map((r) => r.scheduledFor).toList();
      expect(times.toSet(), hasLength(times.length), reason: 'no time twice');
    },
  );

  // Without a lock provider runs may overlap, but each time still runs once:
  // that rests on the conditional claim alone. The repository yields on every
  // call like a database, so the instances really race for the claim.
  declareTest(
    'runs each time once with multiple instances without a lock provider',
    [
      const _YieldingRecordRepository(),
      for (var i = 0; i < 3; i++)
        _instance(i, [
          Schedule.every(
            'claimed',
            _record,
            interval: const Duration(milliseconds: 150),
          ),
        ]),
    ],
    () async {
      await _eventually(() => _runsOf('claimed').length >= 5, reason: '5 runs');

      final times = _runsOf('claimed').map((r) => r.scheduledFor).toList();
      expect(times.toSet(), hasLength(times.length), reason: 'no time twice');
    },
  );

  final missed = DateTime.timestamp().subtract(const Duration(hours: 1));
  declareTest(
    'makes up for missed runs with one run',
    [
      ..._shared(
        records: [ScheduleRecord(id: 'missed', nextRunAt: missed)],
      ),
      _instance(0, [
        Schedule.every(
          'missed',
          _record,
          interval: const Duration(minutes: 10),
        ),
      ]),
    ],
    () async {
      await _eventually(() => _runsOf('missed').isNotEmpty, reason: 'a run');
      await Future.delayed(const Duration(milliseconds: 300));

      expect(_runsOf('missed').single.scheduledFor, missed);
      final record = (await _records.readById('missed'))!;
      expect(record.nextRunAt.isAfter(DateTime.timestamp()), isTrue);
    },
  );

  var active = 0;
  var maxActive = 0;
  declareTest(
    'does not overlap runs',
    [
      ..._shared(),
      for (var i = 0; i < 2; i++)
        _instance(i, [
          Schedule.every('slow', (run) async {
            active++;
            maxActive = active > maxActive ? active : maxActive;
            await Future.delayed(const Duration(milliseconds: 350));
            active--;
            await _record(run);
          }, interval: const Duration(milliseconds: 100)),
        ]),
    ],
    () async {
      await _eventually(() => _runsOf('slow').length >= 3, reason: '3 runs');
      expect(maxActive, 1);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  declareTest(
    'does not run schedules on instances that are not workers',
    [
      ..._shared(),
      _instance(0, [
        Schedule.every(
          'idle',
          _record,
          interval: const Duration(milliseconds: 50),
        ),
      ], worker: false),
    ],
    () async {
      await Future.delayed(const Duration(milliseconds: 400));
      expect(_runsOf('idle'), isEmpty);
    },
  );

  declareTest(
    'stores the error and the log of a failed run',
    [
      ..._shared(),
      _instance(0, [
        Schedule.every('failing', (run) async {
          log.info('Fetching rates.');
          throw ApiRequestException(503, 'Rates API not available.');
        }, interval: const Duration(milliseconds: 100)),
      ]),
    ],
    () async {
      await _eventually(
        () async => (await _records.readById('failing'))?.lastError != null,
        reason: 'the failure to be stored',
      );

      final record = (await _records.readById('failing'))!;
      expect(record.lastError, contains('Rates API not available.'));
      final message = jsonDecode(record.lastMessages.first) as Map;
      expect(message['msg'], 'Fetching rates.');

      final failed = Find<Telemetry>()
          .find()
          .counter('scheduler_runs_total')
          .collect()
          .samples
          .where(
            (s) =>
                s.labels['schedule'] == 'failing' &&
                s.labels['outcome'] == 'failed',
          );
      expect(failed.single.value, greaterThanOrEqualTo(1));
    },
  );

  declareTest(
    'runs a schedule now on request',
    [Schedule.monthly('billing', _record)],
    () async {
      await Future.delayed(const Duration(milliseconds: 200));
      expect(_runsOf('billing'), isEmpty);

      await Find<Scheduler>().find().runNow('billing');
      await _eventually(() => _runsOf('billing').isNotEmpty, reason: 'a run');

      await expectLater(
        Find<Scheduler>().find().runNow('unknown'),
        throwsA(isA<ApiRequestException>()),
      );
    },
  );
}

/// An in-memory `DataRepository<ScheduleRecord>` that yields on every call,
/// like a database. Each call itself is atomic.
class _YieldingRecordRepository implements Service {
  const _YieldingRecordRepository();

  @override
  ServiceInstance<_YieldingRecordRepository> createInstance() =>
      _YieldingRecordRepositoryInstance();
}

class _YieldingRecordRepositoryInstance
    extends ServiceInstance<_YieldingRecordRepository>
    implements DataRepository<ScheduleRecord> {
  final _records = <String, ScheduleRecord>{};

  Future<void> _yield() => Future.delayed(const Duration(milliseconds: 1));

  @override
  DataBean<ScheduleRecord> get bean => $ScheduleRecord.bean;

  @override
  Future<ScheduleRecord> create(ScheduleRecord element) async {
    await _yield();
    if (_records.containsKey(element.id)) {
      throw ApiException('Duplicate id.');
    }
    return _records[element.id] = element;
  }

  @override
  Future<ScheduleRecord?> readById(dynamic id) async {
    await _yield();
    return _records[id];
  }

  @override
  Future<List<ScheduleRecord>> readAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int? offset,
    int? limit,
  }) async {
    await _yield();
    return _records.values.where(filter.matches).toList();
  }

  @override
  Future<int> count({Filter filter = Filter.empty}) async =>
      (await readAll(filter: filter)).length;

  @override
  Future<bool> any({Filter filter = Filter.empty}) async =>
      (await count(filter: filter)) > 0;

  @override
  Future<ScheduleRecord?> first({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
  }) async => (await readAll(filter: filter)).firstOrNull;

  @override
  Future<bool> updateById(ScheduleRecord element) async {
    await _yield();
    if (!_records.containsKey(element.id)) {
      return false;
    }
    _records[element.id] = element;
    return true;
  }

  @override
  Future<int> updateAll({
    required Filter filter,
    required Map<DataField<ScheduleRecord, dynamic>, dynamic> values,
  }) async {
    await _yield();
    var count = 0;
    for (final record in _records.values.where(filter.matches).toList()) {
      _records[record.id] = bean.fromValues({
        for (final field in bean.fields) field.name: field.valueOf(record),
        for (final MapEntry(key: field, :value) in values.entries)
          field.name: value,
      });
      count++;
    }
    return count;
  }

  @override
  Future<bool> deleteById(dynamic id) async {
    await _yield();
    return _records.remove(id) != null;
  }

  @override
  Future<int> deleteAll({required Filter filter}) async {
    await _yield();
    final ids = [
      for (final record in _records.values)
        if (filter.matches(record)) record.id,
    ];
    ids.forEach(_records.remove);
    return ids.length;
  }

  @override
  Future<R> atomic<R>(Future<R> Function() delegate) => delegate();
}
