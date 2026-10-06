// Monthly invoicing with workflows, the guiding case for replacing the
// TaskManager: a billing period per month closes itself at its end, starts one
// invoice per user with open positions and starts the next period. The tests
// use periods of a few hundred milliseconds instead of months.
import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

part 'billing_test.g.dart';

/// Costs of a user that still have to be invoiced.
@Data()
class Position extends $Position {
  @Id(auto: true)
  final String id;
  final String userId;
  final int amount;
  final DateTime date;

  /// The invoice the position was billed with.
  final String? invoiceId;

  const Position({
    this.id = '',
    required this.userId,
    required this.amount,
    required this.date,
    this.invoiceId,
  });
}

enum PeriodState { open, closed }

@Data()
class BillingPeriod extends $BillingPeriod {
  /// `p<index>`, like `2026-11` for months.
  @Id()
  final String id;
  final int index;
  final DateTime end;
  final PeriodState state;

  const BillingPeriod({
    required this.id,
    required this.index,
    required this.end,
    this.state = PeriodState.open,
  });
}

enum BillingInvoiceState { created, assigned }

@Data()
class BillingInvoice extends $BillingInvoice {
  /// `<user>/<period>`, so starting it again does nothing.
  @Id()
  final String id;
  final String userId;
  final DateTime periodEnd;
  final int total;
  final BillingInvoiceState state;

  const BillingInvoice({
    required this.id,
    required this.userId,
    required this.periodEnd,
    this.total = 0,
    this.state = BillingInvoiceState.created,
  });
}

const _periodLength = Duration(milliseconds: 400);

BillingPeriod _period(int index, DateTime end) =>
    BillingPeriod(id: 'p$index', index: index, end: end);

DataRepository<Position> get _positions =>
    Find<DataRepository<Position>>().find();
DataRepository<BillingInvoice> get _invoices =>
    Find<DataRepository<BillingInvoice>>().find();
Workflow<BillingPeriod> get _periodWorkflow =>
    Find<Workflow<BillingPeriod>>().find();
Workflow<BillingInvoice> get _invoiceWorkflow =>
    Find<Workflow<BillingInvoice>>().find();

/// Calls of the steps, by element id.
final _closeCalls = <String, int>{};
final _assignCalls = <String, int>{};

/// Lets the period step fail once after starting the first invoice.
var _failClosingOnce = false;

Future<BillingPeriod> _closePeriod(StepContext<BillingPeriod> step) async {
  final period = step.element;
  _closeCalls.update(period.id, (n) => n + 1, ifAbsent: () => 1);

  final open = await _positions.readAll(
    filter: Filter.andGroup([
      $Position.$invoiceId.equals(null),
      $Position.$date.lessThan(period.end),
    ]),
  );
  final users = {for (final position in open) position.userId}.toList()..sort();
  for (final user in users) {
    await _invoiceWorkflow.start(
      BillingInvoice(
        id: '$user/${period.id}',
        userId: user,
        periodEnd: period.end,
      ),
    );
    if (_failClosingOnce) {
      _failClosingOnce = false;
      throw ApiRequestException(503, 'Interrupted.');
    }
  }

  // The step's own workflow comes from its context.
  await step.workflow.start(
    _period(period.index + 1, period.end.add(_periodLength)),
  );
  return period.copyWith(state: PeriodState.closed);
}

Future<BillingInvoice> _assignPositions(
  StepContext<BillingInvoice> step,
) async {
  final invoice = step.element;
  _assignCalls.update(invoice.id, (n) => n + 1, ifAbsent: () => 1);

  // Only positions that are not billed yet, so running this again is safe.
  await _positions.updateAll(
    filter: Filter.andGroup([
      $Position.$userId.equals(invoice.userId),
      $Position.$invoiceId.equals(null),
      $Position.$date.lessThan(invoice.periodEnd),
    ]),
    values: {$Position.$invoiceId: invoice.id},
  );
  final billed = await _positions.readAll(
    filter: $Position.$invoiceId.equals(invoice.id),
  );
  return invoice.copyWith(
    total: billed.fold<int>(0, (sum, p) => sum + p.amount),
    state: BillingInvoiceState.assigned,
  );
}

List<Component> _components({int instances = 1}) => [
  MemoryRepositoryService(bean: $Position.bean),
  MemoryRepositoryService(bean: $BillingPeriod.bean),
  MemoryRepositoryService(bean: $BillingInvoice.bean),
  MemoryRepositoryService(bean: $WorkflowEvent.bean),
  const MemoryLockService<String>(),
  for (var i = 0; i < instances; i++)
    Scope(
      name: 'instance-$i',
      components: [
        WorkflowService<BillingPeriod, PeriodState>(
          steps: [
            OnEnter(
              PeriodState.open,
              _closePeriod,
              at: (period) => period.end,
              retry: const RetryPolicy(
                initialDelay: Duration(milliseconds: 10),
              ),
            ),
          ],
          pollInterval: Config.value(const Duration(seconds: 10)),
        ),
        WorkflowService<BillingInvoice, BillingInvoiceState>(
          steps: [OnEnter(BillingInvoiceState.created, _assignPositions)],
          pollInterval: Config.value(const Duration(seconds: 10)),
        ),
      ],
    ),
];

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

Future<BillingInvoice?> _invoice(String id) => _invoices.readById(id);

Future<void> _eventuallyAssigned(String id) => _eventually(
  () async => (await _invoice(id))?.state == BillingInvoiceState.assigned,
  reason: 'invoice $id to be assigned',
);

Future<void> _addPosition(String user, int amount, {DateTime? date}) =>
    _positions.create(
      Position(
        userId: user,
        amount: amount,
        date: date ?? DateTime.timestamp(),
      ),
    );

void main() {
  setUp(() {
    _closeCalls.clear();
    _assignCalls.clear();
    _failClosingOnce = false;
  });

  declareTest(
    'creates one invoice per user and period from the open positions',
    _components(),
    () async {
      await _addPosition('alice', 10);
      await _addPosition('alice', 5);
      await _addPosition('bob', 7);

      final end = DateTime.timestamp().add(_periodLength);
      await _periodWorkflow.start(_period(1, end));

      await _eventuallyAssigned('alice/p1');
      await _eventuallyAssigned('bob/p1');
      expect((await _invoice('alice/p1'))!.total, 15);
      expect((await _invoice('bob/p1'))!.total, 7);

      // Positions that come later are billed with a later period (usually the
      // next one, a later one if the machine is slow).
      await _addPosition('alice', 3);
      await _eventually(
        () async => (await _invoices.readAll()).any(
          (invoice) =>
              invoice.userId == 'alice' &&
              invoice.id != 'alice/p1' &&
              invoice.state == BillingInvoiceState.assigned &&
              invoice.total == 3,
        ),
        reason: 'the late position to be billed',
      );
      // Bob had nothing new.
      expect(
        (await _invoices.readAll()).where((invoice) => invoice.userId == 'bob'),
        hasLength(1),
      );

      // Nothing was billed twice.
      expect(
        (await _positions.readAll()).map((p) => p.invoiceId),
        everyElement(isNotNull),
      );
      expect(_assignCalls.values, everyElement(1));
    },
  );

  declareTest(
    'closes a period right away if its end has passed',
    _components(),
    () async {
      // For example after the service was down at the end of the period.
      final end = DateTime.timestamp().subtract(const Duration(hours: 1));
      await _addPosition(
        'alice',
        10,
        date: end.subtract(const Duration(days: 1)),
      );
      await _periodWorkflow.start(_period(1, end));

      await _eventuallyAssigned('alice/p1');
    },
  );

  declareTest(
    'does not create invoices twice when the period step runs again',
    _components(),
    () async {
      await _addPosition('alice', 10);
      await _addPosition('bob', 7);
      _failClosingOnce = true;

      await _periodWorkflow.start(
        _period(1, DateTime.timestamp().add(_periodLength)),
      );
      await _eventuallyAssigned('alice/p1');
      await _eventuallyAssigned('bob/p1');

      expect(_closeCalls['p1'], 2, reason: 'failed once, then succeeded');
      expect(_assignCalls, {'alice/p1': 1, 'bob/p1': 1});
      expect(await _invoices.readAll(), hasLength(2));
    },
  );

  declareTest(
    'closes every period once with multiple instances',
    _components(instances: 3),
    () async {
      for (final user in ['alice', 'bob', 'carol', 'dave']) {
        await _addPosition(user, 1);
      }

      await _periodWorkflow.start(
        _period(1, DateTime.timestamp().add(_periodLength)),
      );
      for (final user in ['alice', 'bob', 'carol', 'dave']) {
        await _eventuallyAssigned('$user/p1');
      }
      await _eventually(() => _closeCalls.containsKey('p2'), reason: 'p2');

      expect(_closeCalls['p1'], 1);
      expect(_assignCalls.values, everyElement(1));
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  group('idempotent start', () {
    BillingInvoice invoice() => BillingInvoice(
      id: 'alice/p1',
      userId: 'alice',
      periodEnd: DateTime.timestamp().add(const Duration(days: 1)),
    );

    declareTest(
      'does not start an existing element again',
      _components(),
      () async {
        await _addPosition('alice', 10);
        await _invoiceWorkflow.start(invoice());
        await _eventuallyAssigned('alice/p1');

        final again = await _invoiceWorkflow.start(invoice());
        expect(again.state, BillingInvoiceState.assigned);

        await Future.delayed(const Duration(milliseconds: 200));
        expect(_assignCalls['alice/p1'], 1);
      },
    );

    declareTest(
      'starts an element whose start was interrupted',
      _components(),
      () async {
        await _addPosition('alice', 10);
        // Stored, but the process died before it entered the workflow.
        await _invoices.create(invoice());

        await _invoiceWorkflow.start(invoice());
        await _eventuallyAssigned('alice/p1');
      },
    );

    declareTest(
      'starts an element once when it is started concurrently',
      _components(),
      () async {
        await _addPosition('alice', 10);

        await Future.wait([
          for (var i = 0; i < 3; i++) _invoiceWorkflow.start(invoice()),
        ]);
        await _eventuallyAssigned('alice/p1');

        await Future.delayed(const Duration(milliseconds: 200));
        expect(_assignCalls['alice/p1'], 1);
      },
    );
  });
}
