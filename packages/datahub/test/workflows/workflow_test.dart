import 'dart:async';
import 'dart:convert';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

part 'workflow_test.g.dart';

@Data()
class Invoice extends $Invoice {
  const Invoice({
    this.id = '',
    required this.recipient,
    required this.invoiceFile,
    required this.amount,
    this.state = InvoiceWorkflowState.created,
    this.paymentReference,
  });

  @Id(auto: true)
  final String id;

  final String recipient;
  final String? invoiceFile;
  final String? paymentReference;
  final int amount;

  final InvoiceWorkflowState state;
}

@Data()
class PaymentSuccessSignal extends $PaymentSuccessSignal
    implements WorkflowSignal<Invoice> {
  final String invoiceId;
  final String reference;

  const PaymentSuccessSignal({
    required this.invoiceId,
    required this.reference,
  });
}

@Data()
class PaymentFailedSignal extends $PaymentFailedSignal
    implements WorkflowSignal<Invoice> {
  final String invoiceId;
  final String reference;
  final String reason;

  const PaymentFailedSignal({
    required this.invoiceId,
    required this.reference,
    required this.reason,
  });
}

/// A signal that no step of the invoice workflow handles.
@Data()
class UnhandledSignal extends $UnhandledSignal
    implements WorkflowSignal<Invoice> {
  final String note;

  const UnhandledSignal({this.note = ''});
}

/// A signal for the workflow of another element type.
@Data()
class ForeignSignal extends $ForeignSignal
    implements WorkflowSignal<WorkflowEvent> {
  final String note;

  const ForeignSignal({this.note = ''});
}

enum InvoiceWorkflowState {
  created,
  generated,
  paymentRequested,
  paymentReceived,
  paymentFailed,
}

typedef InvoiceStep = WorkflowStep<Invoice, InvoiceWorkflowState>;
typedef InvoiceHandler = Future<Invoice> Function(StepContext<Invoice>);
typedef PaymentHandler =
    Future<Invoice> Function(
      SignalStepContext<Invoice, PaymentSuccessSignal> context,
    );

const _fastRetry = RetryPolicy(
  maxAttempts: 3,
  initialDelay: Duration(milliseconds: 10),
  backoffFactor: 1,
);

Future<Invoice> _generate(StepContext<Invoice> step) async =>
    step.element.copyWith(
      state: InvoiceWorkflowState.generated,
      invoiceFile: 'invoice-${step.element.id}.pdf',
    );

Future<Invoice> _requestPayment(StepContext<Invoice> step) async =>
    step.element.copyWith(state: InvoiceWorkflowState.paymentRequested);

Future<Invoice> _processPayment(
  SignalStepContext<Invoice, PaymentSuccessSignal> step,
) async => step.element.copyWith(
  state: InvoiceWorkflowState.paymentReceived,
  paymentReference: step.signal.reference,
);

/// The invoice workflow:
///
/// created -> generated -> paymentRequested -> paymentReceived / paymentFailed
///
/// The last step is triggered by signals from the payment provider.
List<InvoiceStep> _steps({
  InvoiceHandler? generate,
  Duration generateAfter = Duration.zero,
  InvoiceHandler? requestPayment,
  RetryPolicy retry = _fastRetry,
  InvoiceWorkflowState? failureState,
  PaymentHandler? processPayment,
  RetryPolicy signalRetry = _fastRetry,
  InvoiceWorkflowState? signalFailureState,
  Duration signalExpireAfter = const Duration(seconds: 10),
  List<InvoiceStep> extra = const [],
}) => [
  OnEnter(
    InvoiceWorkflowState.created,
    generate ?? _generate,
    after: generateAfter,
    retry: _fastRetry,
  ),
  OnEnter(
    InvoiceWorkflowState.generated,
    requestPayment ?? _requestPayment,
    retry: retry,
    failureState: failureState,
  ),
  OnSignal(
    $PaymentSuccessSignal.bean,
    accept: [InvoiceWorkflowState.paymentRequested],
    target: (signal) => signal.invoiceId,
    retry: signalRetry,
    failureState: signalFailureState,
    expireAfter: signalExpireAfter,
    handle: processPayment ?? _processPayment,
  ),
  OnSignal(
    $PaymentFailedSignal.bean,
    accept: [InvoiceWorkflowState.paymentRequested],
    target: (signal) => signal.invoiceId,
    retry: signalRetry,
    expireAfter: signalExpireAfter,
    handle: (step) async =>
        step.element.copyWith(state: InvoiceWorkflowState.paymentFailed),
  ),
  ...extra,
];

List<Component> _components(
  List<InvoiceStep> steps, {
  int instances = 1,
  List<bool>? workers,
  bool history = false,
  Duration pollInterval = const Duration(milliseconds: 20),
  Duration heartbeatInterval = const Duration(seconds: 10),
}) => [
  MemoryRepositoryService(bean: $Invoice.bean),
  MemoryRepositoryService(bean: $WorkflowEvent.bean),
  if (history) MemoryRepositoryService(bean: $WorkflowHistoryEntry.bean),
  // Shared by all instances, which is what a distributed lock provider is for.
  const MemoryLockService<String>(),
  for (final (i, worker) in (workers ?? List.filled(instances, true)).indexed)
    Scope(
      name: 'instance-$i',
      components: [
        WorkflowService<Invoice, InvoiceWorkflowState>(
          steps: steps,
          pollInterval: Config.value(pollInterval),
          heartbeatInterval: Config.value(heartbeatInterval),
          worker: Config.value(worker),
          workerId: Config.value('worker-$i'),
        ),
      ],
    ),
];

DataRepository<Invoice> get _invoices => Find<DataRepository<Invoice>>().find();

DataRepository<WorkflowEvent> get _events =>
    Find<DataRepository<WorkflowEvent>>().find();

Workflow<Invoice> get _workflow => Find<Workflow<Invoice>>().find();

/// A session of the tests, [identity] tells who acts.
class _Session implements Session {
  @override
  final String identity;

  const _Session(this.identity);

  @override
  String get debugName => identity;
}

const _engine = _Session('engine');

/// The identity a repository call ran with, null without a session.
String? get _actor => switch (Context.maybeOfZone()?.sessions) {
  [] || null => null,
  [final Session session] => session.identity,
  final sessions => sessions.map((s) => s.identity).join('+'),
};

/// Who did what to which repository, as (repository, operation, actor).
final _calls = <(String, String, String?)>[];

/// Who may not do what, by repository and operation.
const _forbidden = {
  ('Invoice', 'create'): {'mallory'},
  ('Invoice', 'update'): {'clerk'},
};

/// A repository that notes who calls it, and refuses what is [_forbidden].
/// It works on the other `DataRepository<T>`.
class _Watched<T extends DataObject> implements Service {
  const _Watched();

  @override
  ServiceInstance<_Watched<T>> createInstance() => _WatchedInstance<T>();
}

class _WatchedInstance<T extends DataObject>
    extends ServiceInstance<_Watched<T>>
    implements DataRepository<T> {
  late final DataRepository<T> _inner;

  @override
  Future<void> initialize() async {
    await super.initialize();
    _inner = find(Find<DataRepository<T>>((r) => r is! _WatchedInstance));
  }

  String get _name => _inner.bean.name;

  Future<R> _note<R>(String operation, Future<R> Function() call) async {
    _calls.add((_name, operation, _actor));
    if (_forbidden[(_name, operation)]?.contains(_actor) ?? false) {
      throw ApiRequestException(403, 'Not allowed to $operation.');
    }
    return await call();
  }

  @override
  DataBean<T> get bean => _inner.bean;

  @override
  Future<T> create(T element) => _note('create', () => _inner.create(element));

  @override
  Future<T?> readById(
    dynamic id, {
    bool locked = false,
    bool skipLocked = false,
  }) => _note(
    'read',
    () => _inner.readById(id, locked: locked, skipLocked: skipLocked),
  );

  @override
  Future<List<T>> readAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int? offset,
    int? limit,
    bool locked = false,
    bool skipLocked = false,
  }) => _note(
    'read',
    () => _inner.readAll(
      filter: filter,
      sort: sort,
      offset: offset,
      limit: limit,
      locked: locked,
      skipLocked: skipLocked,
    ),
  );

  @override
  Future<int> count({Filter filter = Filter.empty}) =>
      _note('read', () => _inner.count(filter: filter));

  @override
  Future<bool> updateById(T element) =>
      _note('update', () => _inner.updateById(element));

  @override
  Future<int> updateAll({
    required Filter filter,
    required Map<DataField<T, dynamic>, dynamic> values,
  }) => _note('update', () => _inner.updateAll(filter: filter, values: values));

  @override
  Future<bool> deleteById(dynamic id) =>
      _note('delete', () => _inner.deleteById(id));

  @override
  Future<int> deleteAll({required Filter filter}) =>
      _note('delete', () => _inner.deleteAll(filter: filter));

  @override
  Future<R> atomic<R>(Future<R> Function() delegate) => _inner.atomic(delegate);

  @override
  Future<T?> first({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
    bool locked = false,
    bool skipLocked = false,
  }) => _note(
    'read',
    () => _inner.first(
      filter: filter,
      sort: sort,
      offset: offset,
      locked: locked,
      skipLocked: skipLocked,
    ),
  );

  @override
  Future<bool> any({
    Filter filter = Filter.empty,
    bool locked = false,
    bool skipLocked = false,
  }) => _note(
    'read',
    () => _inner.any(filter: filter, locked: locked, skipLocked: skipLocked),
  );
}

/// The invoice workflow with the engine acting as [_engine], and all
/// repositories watched.
List<Component> _watchedComponents(
  List<InvoiceStep> steps, {
  Duration heartbeatInterval = const Duration(seconds: 10),
}) => [
  MemoryRepositoryService(bean: $Invoice.bean),
  MemoryRepositoryService(bean: $WorkflowEvent.bean),
  MemoryRepositoryService(bean: $WorkflowHistoryEntry.bean),
  const _Watched<Invoice>(),
  const _Watched<WorkflowEvent>(),
  const _Watched<WorkflowHistoryEntry>(),
  const MemoryLockService<String>(),
  WorkflowService<Invoice, InvoiceWorkflowState>(
    steps: steps,
    workerSession: _engine,
    repository: const Find<_WatchedInstance<Invoice>>(),
    eventRepository: const Find<_WatchedInstance<WorkflowEvent>>(),
    historyRepository: const Find<_WatchedInstance<WorkflowHistoryEntry>>(),
    pollInterval: const Config.value(Duration(milliseconds: 20)),
    heartbeatInterval: Config.value(heartbeatInterval),
  ),
];

/// Runs [body] as the caller [identity].
Future<R> _as<R>(String identity, Future<R> Function() body) =>
    Context.ofZone().withSession(_Session(identity), body);

/// The actors of the calls to [repository], optionally of one [operation].
Set<String?> _actors(String repository, [String? operation]) => {
  for (final (name, op, actor) in _calls)
    if (name == repository && (operation == null || op == operation)) actor,
};

Future<Invoice> _start([
  InvoiceWorkflowState state = InvoiceWorkflowState.created,
]) => _workflow.start(
  Invoice(recipient: 'Tester', invoiceFile: null, amount: 123, state: state),
);

Future<Invoice> _read(String id) async => (await _invoices.readById(id))!;

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

Future<void> _eventuallyInState(String id, InvoiceWorkflowState state) =>
    _eventually(
      () async => (await _read(id)).state == state,
      reason: 'invoice $id to be in state ${state.name}',
    );

Future<void> _eventuallyNoEvents() => _eventually(
  () async => (await _events.readAll()).isEmpty,
  reason: 'all events to be handled',
);

Future<void> _eventuallyEvent(WorkflowEventStatus status) => _eventually(
  () async => (await _events.readAll()).any((e) => e.status == status),
  reason: 'an event to be ${status.name}',
);

void main() {
  group('WorkflowService.validate', () {
    void validate(List<InvoiceStep> steps) =>
        WorkflowService<Invoice, InvoiceWorkflowState>(
          steps: steps,
        ).validate($Invoice.bean);

    OnEnter<Invoice, InvoiceWorkflowState> onEnter(
      InvoiceWorkflowState state, {
      String? name,
      InvoiceWorkflowState? failureState,
      Duration after = Duration.zero,
    }) => OnEnter(
      state,
      (step) async => step.element,
      name: name,
      failureState: failureState,
      after: after,
    );

    OnSignal<Invoice, InvoiceWorkflowState, PaymentSuccessSignal> onSignal({
      String? name,
      List<InvoiceWorkflowState> accept = const [
        InvoiceWorkflowState.paymentRequested,
      ],
      Duration expireAfter = const Duration(days: 1),
    }) => OnSignal(
      $PaymentSuccessSignal.bean,
      name: name,
      accept: accept,
      expireAfter: expireAfter,
      target: (signal) => signal.invoiceId,
      handle: (step) async => step.element,
    );

    test('accepts a valid workflow', () {
      validate(_steps());
    });

    test('accepts several steps for a state with different delays', () {
      validate([
        onEnter(InvoiceWorkflowState.created),
        onEnter(InvoiceWorkflowState.created, after: const Duration(days: 1)),
      ]);
    });

    test('rejects workflows without steps', () {
      expect(
        () => validate([]),
        throwsA(
          isA<ApiError>().having(
            (e) => e.message,
            'message',
            contains('no steps'),
          ),
        ),
      );
    });

    test('rejects steps with the same name', () {
      expect(
        () => validate([
          onEnter(InvoiceWorkflowState.created),
          onEnter(InvoiceWorkflowState.created),
        ]),
        throwsA(isA<ApiError>()),
      );
      validate([
        onEnter(InvoiceWorkflowState.created),
        onEnter(InvoiceWorkflowState.created, name: 'other'),
      ]);
    });

    test('rejects negative delays', () {
      expect(
        () => validate([
          onEnter(
            InvoiceWorkflowState.created,
            after: const Duration(seconds: -1),
          ),
        ]),
        throwsA(isA<ApiError>()),
      );
    });

    test('rejects a step that is its own failure state', () {
      expect(
        () => validate([
          onEnter(
            InvoiceWorkflowState.created,
            failureState: InvoiceWorkflowState.created,
          ),
        ]),
        throwsA(isA<ApiError>()),
      );
    });

    test('rejects signal steps that do not accept any state', () {
      expect(
        () => validate([onSignal(accept: const [])]),
        throwsA(isA<ApiError>()),
      );
    });

    test('rejects multiple steps for the same signal', () {
      expect(
        () => validate([onSignal(), onSignal(name: 'other')]),
        throwsA(isA<ApiError>()),
      );
    });

    test('rejects signal steps that expire their signals immediately', () {
      expect(
        () => validate([onSignal(expireAfter: Duration.zero)]),
        throwsA(isA<ApiError>()),
      );
    });

    test('rejects signal steps for signals of another element type', () {
      expect(
        () => validate([
          OnSignal(
            // ignore: datahub_lints/workflow_signal_not_for_element
            $ForeignSignal.bean,
            accept: [InvoiceWorkflowState.paymentRequested],
            target: (signal) => signal.note,
            handle: (step) async => step.element,
          ),
        ]),
        throwsA(
          isA<ApiError>().having(
            (e) => e.message,
            'message',
            contains('not a signal for Invoice'),
          ),
        ),
      );
    });
  });

  group('RetryPolicy', () {
    test('grows the delay exponentially up to the maximum', () {
      const policy = RetryPolicy(
        maxAttempts: 10,
        initialDelay: Duration(seconds: 1),
        backoffFactor: 2,
        maxDelay: Duration(seconds: 5),
      );
      expect(policy.delayAfter(1), const Duration(seconds: 1));
      expect(policy.delayAfter(2), const Duration(seconds: 2));
      expect(policy.delayAfter(3), const Duration(seconds: 4));
      expect(policy.delayAfter(4), const Duration(seconds: 5));
      expect(policy.delayAfter(20), const Duration(seconds: 5));
    });

    test('allows retries until maxAttempts is reached', () {
      const policy = RetryPolicy(maxAttempts: 3);
      expect(policy.allowsRetryAfter(1), isTrue);
      expect(policy.allowsRetryAfter(2), isTrue);
      expect(policy.allowsRetryAfter(3), isFalse);
      expect(const RetryPolicy.none().allowsRetryAfter(1), isFalse);
    });
  });

  declareTest(
    'runs steps from the start until the workflow waits for a signal',
    _components(_steps()),
    () async {
      final invoice = await _start();
      await _eventuallyInState(
        invoice.id,
        InvoiceWorkflowState.paymentRequested,
      );
      expect(
        (await _read(invoice.id)).invoiceFile,
        'invoice-${invoice.id}.pdf',
      );
      await _eventuallyNoEvents();

      await _workflow.send(
        PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref-1'),
      );
      await _eventuallyInState(
        invoice.id,
        InvoiceWorkflowState.paymentReceived,
      );
      expect((await _read(invoice.id)).paymentReference, 'ref-1');
      await _eventuallyNoEvents();
    },
  );

  declareTest(
    'ignores elements that were not started, until they are resumed',
    _components(_steps()),
    () async {
      final invoice = await _invoices.create(
        Invoice(recipient: 'Tester', invoiceFile: null, amount: 123),
      );

      await Future.delayed(const Duration(milliseconds: 200));
      expect((await _read(invoice.id)).state, InvoiceWorkflowState.created);

      await _workflow.resume(invoice.id);
      await _eventuallyInState(
        invoice.id,
        InvoiceWorkflowState.paymentRequested,
      );
    },
  );

  declareTest(
    'replaces the pending steps of an element that is resumed',
    _components(
      _steps(generateAfter: const Duration(seconds: 1)),
      history: true,
    ),
    () async {
      final invoice = await _start();
      Future<List<String>> pendingSteps() async => [
        for (final event in await _workflow.events(elementId: invoice.id))
          event.step,
      ];
      final steps = await pendingSteps();
      expect(steps, hasLength(1));

      // In the same state, the step does not run twice.
      await _workflow.resume(invoice.id);
      expect(await pendingSteps(), steps);

      // Moved to another state outside of the workflow, the step of the state
      // it left is cancelled (paymentRequested has no steps of its own).
      await _invoices.updateById(
        (await _read(
          invoice.id,
        )).copyWith(state: InvoiceWorkflowState.paymentRequested),
      );
      await _workflow.resume(invoice.id);
      expect(await pendingSteps(), isEmpty);

      expect((await _workflow.history(invoice.id)).map((e) => e.kind), [
        WorkflowHistoryKind.started,
        WorkflowHistoryKind.cancelled,
        WorkflowHistoryKind.resumed,
        WorkflowHistoryKind.cancelled,
        WorkflowHistoryKind.resumed,
      ]);
    },
  );

  var restingCalls = 0;
  declareTest(
    'lets a step leave the element in its state',
    _components(
      _steps(
        generate: (step) async {
          restingCalls++;
          return step.element.copyWith(invoiceFile: 'draft.pdf');
        },
      ),
    ),
    () async {
      final invoice = await _start();
      await _eventually(
        () async => (await _read(invoice.id)).invoiceFile == 'draft.pdf',
        reason: 'the step to run',
      );
      await _eventuallyNoEvents();

      // It does not run again, there is no new event for it.
      await Future.delayed(const Duration(milliseconds: 200));
      expect(restingCalls, 1);
      expect((await _read(invoice.id)).state, InvoiceWorkflowState.created);
    },
  );

  group('failing steps', () {
    final calls = <StepContext<Invoice>>[];
    declareTest(
      'retries a failing step with the same idempotency key',
      _components(
        _steps(
          requestPayment: (step) async {
            calls.add(step);
            if (calls.length < 3) {
              throw ApiRequestException(503, 'Payment API not available.');
            }
            return step.element.copyWith(
              state: InvoiceWorkflowState.paymentRequested,
            );
          },
        ),
      ),
      () async {
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );

        expect(calls.map((c) => c.attempt), [1, 2, 3]);
        expect(calls.map((c) => c.idempotencyKey).toSet(), hasLength(1));
      },
    );

    var failureStateCalls = 0;
    declareTest(
      'moves the element to the failure state when all attempts failed',
      _components(
        _steps(
          retry: const RetryPolicy(
            maxAttempts: 2,
            initialDelay: Duration(milliseconds: 10),
          ),
          failureState: InvoiceWorkflowState.paymentFailed,
          requestPayment: (step) async {
            failureStateCalls++;
            throw ApiRequestException(503, 'Payment API not available.');
          },
        ),
      ),
      () async {
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentFailed,
        );

        expect(failureStateCalls, 2);
        await _eventuallyNoEvents();
      },
    );

    var parkedCalls = 0;
    declareTest(
      'parks the event when all attempts failed and there is no failure state',
      _components(
        _steps(
          retry: const RetryPolicy(
            maxAttempts: 2,
            initialDelay: Duration(milliseconds: 10),
          ),
          requestPayment: (step) async {
            parkedCalls++;
            throw ApiRequestException(503, 'Payment API not available.');
          },
        ),
      ),
      () async {
        final invoice = await _start();
        await _eventuallyEvent(WorkflowEventStatus.failed);

        final event = (await _events.readAll()).single;
        expect(event.attempts, 2);
        expect(event.lastError, contains('Payment API not available.'));
        expect((await _read(invoice.id)).state, InvoiceWorkflowState.generated);

        // Parked events are left alone.
        await Future.delayed(const Duration(milliseconds: 200));
        expect(parkedCalls, 2);

        // Setting it back to pending gives it another round of attempts.
        await _events.updateById(
          event.copyWith(status: WorkflowEventStatus.pending, attempts: 0),
        );
        await _eventually(() => parkedCalls == 4, reason: 'a second round');
      },
    );
  });

  group('delays', () {
    declareTest(
      'runs a delayed step after its delay',
      _components(_steps(generateAfter: const Duration(milliseconds: 600))),
      () async {
        final stopwatch = Stopwatch()..start();
        final invoice = await _start();

        await Future.delayed(const Duration(milliseconds: 250));
        expect((await _read(invoice.id)).state, InvoiceWorkflowState.created);

        await _eventually(
          () async => (await _read(invoice.id)).invoiceFile != null,
          reason: 'the delayed step to run',
        );
        expect(
          stopwatch.elapsed,
          greaterThanOrEqualTo(const Duration(milliseconds: 600)),
        );
      },
    );

    // A delayed step is a timeout: cancel invoices that were not paid in time.
    var cancelCalls = 0;
    InvoiceStep cancelUnpaid() => OnEnter(
      InvoiceWorkflowState.paymentRequested,
      (step) async {
        cancelCalls++;
        return step.element.copyWith(state: InvoiceWorkflowState.paymentFailed);
      },
      after: const Duration(milliseconds: 400),
    );

    declareTest(
      'runs a delayed step if the element is still in its state',
      _components(_steps(extra: [cancelUnpaid()])),
      () async {
        cancelCalls = 0;
        final invoice = await _start();

        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentFailed,
        );
        expect(cancelCalls, 1);
      },
    );

    declareTest(
      'cancels a delayed step when the element leaves its state',
      _components(_steps(extra: [cancelUnpaid()])),
      () async {
        cancelCalls = 0;
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );

        await _workflow.send(
          PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
        );
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );

        // Leaving the state cancelled the timeout right away, long before it
        // would have been due.
        await _eventually(
          () async => (await _events.readAll()).isEmpty,
          timeout: const Duration(milliseconds: 250),
          reason: 'the timeout to be cancelled',
        );

        await Future.delayed(const Duration(milliseconds: 600));
        expect(cancelCalls, 0);
        expect(
          (await _read(invoice.id)).state,
          InvoiceWorkflowState.paymentReceived,
        );
      },
    );
  });

  group('signals', () {
    declareTest(
      'does not make the sender wait for the step',
      _components(
        _steps(
          processPayment: (step) async {
            await Future.delayed(const Duration(milliseconds: 400));
            return _processPayment(step);
          },
        ),
      ),
      () async {
        final invoice = await _start(InvoiceWorkflowState.paymentRequested);

        final stopwatch = Stopwatch()..start();
        await _workflow.send(
          PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
        );
        expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 200)));

        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );
      },
    );

    // The payment provider may answer before the step that requested the
    // payment has written its result. The signal must not get lost then, and
    // the sender must not be bothered with it.
    final paymentRequestStarted = Completer<void>();
    final paymentRequestMayFinish = Completer<void>();
    declareTest(
      'applies a signal that overtakes the step that causes it',
      _components(
        _steps(
          requestPayment: (step) async {
            paymentRequestStarted.complete();
            await paymentRequestMayFinish.future;
            return _requestPayment(step);
          },
        ),
      ),
      () async {
        addTearDown(() {
          if (!paymentRequestMayFinish.isCompleted) {
            paymentRequestMayFinish.complete();
          }
        });

        final invoice = await _start();
        await paymentRequestStarted.future;

        await _workflow.send(
          PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
        );
        expect((await _read(invoice.id)).state, InvoiceWorkflowState.generated);

        paymentRequestMayFinish.complete();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );
        expect((await _read(invoice.id)).paymentReference, 'ref');
      },
    );

    declareTest(
      'applies a signal that is sent before its element reached the state',
      _components(_steps(generateAfter: const Duration(milliseconds: 300))),
      () async {
        final invoice = await _start();

        await _workflow.send(
          PaymentSuccessSignal(invoiceId: invoice.id, reference: 'early'),
        );
        expect((await _read(invoice.id)).state, InvoiceWorkflowState.created);

        // The workflow gets there by itself, the signal is applied then.
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );
        expect((await _read(invoice.id)).paymentReference, 'early');
      },
    );

    declareTest(
      'stores a signal while its element is busy and applies it afterwards',
      _components(_steps()),
      () async {
        final invoice = await _start(InvoiceWorkflowState.paymentRequested);

        final lock = await Find<LockProvider<String>>().find().acquireLock(
          'workflow:Invoice:${invoice.id}',
        );
        await _workflow.send(
          PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
        );

        // The signal is stored, so it survives until the element is free.
        final stored = (await _events.readAll()).single;
        expect(stored.status, WorkflowEventStatus.pending);
        expect(stored.step, 'PaymentSuccessSignal');
        expect(stored.elementId, invoice.id);
        expect(stored.payload?['reference'], 'ref');

        await Future.delayed(const Duration(milliseconds: 150));
        expect(
          (await _read(invoice.id)).state,
          InvoiceWorkflowState.paymentRequested,
        );

        await lock.release();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );
      },
    );

    declareTest(
      'does not apply a duplicate of an applied signal',
      _components(_steps(signalExpireAfter: const Duration(milliseconds: 200))),
      () async {
        final invoice = await _start(InvoiceWorkflowState.paymentRequested);
        await _workflow.send(
          PaymentSuccessSignal(invoiceId: invoice.id, reference: 'first'),
        );
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );

        await _workflow.send(
          PaymentSuccessSignal(invoiceId: invoice.id, reference: 'second'),
        );

        // The duplicate waits for a state that never comes and expires.
        await _eventuallyEvent(WorkflowEventStatus.expired);
        expect((await _read(invoice.id)).paymentReference, 'first');
      },
    );

    declareTest(
      'parks a signal for an element that does not exist',
      _components(_steps(signalExpireAfter: const Duration(milliseconds: 200))),
      () async {
        await _workflow.send(
          const PaymentSuccessSignal(invoiceId: 'unknown', reference: 'ref'),
        );

        await _eventuallyEvent(WorkflowEventStatus.expired);
        final event = (await _events.readAll()).single;
        expect(event.lastError, contains('not applied within'));
      },
    );

    declareTest(
      'parks a signal that its element never accepts',
      _components(_steps(signalExpireAfter: const Duration(milliseconds: 200))),
      () async {
        final invoice = await _start(InvoiceWorkflowState.paymentReceived);

        // A late failure notice must not move a paid invoice around.
        await _workflow.send(
          PaymentFailedSignal(
            invoiceId: invoice.id,
            reference: 'ref',
            reason: 'too late',
          ),
        );

        await _eventuallyEvent(WorkflowEventStatus.expired);
        expect(
          (await _read(invoice.id)).state,
          InvoiceWorkflowState.paymentReceived,
        );
      },
    );

    declareTest(
      'drops signals that no step handles',
      _components(_steps()),
      () async {
        await _workflow.send(const UnhandledSignal());

        expect(await _events.readAll(), isEmpty);
      },
    );

    group('failing steps', () {
      final calls = <SignalStepContext<Invoice, PaymentSuccessSignal>>[];
      declareTest(
        'retries a failing step without involving the sender',
        _components(
          _steps(
            processPayment: (step) async {
              calls.add(step);
              if (calls.length < 3) {
                throw ApiRequestException(503, 'Payment API not available.');
              }
              return _processPayment(step);
            },
          ),
        ),
        () async {
          final invoice = await _start(InvoiceWorkflowState.paymentRequested);

          // Does not throw, whatever the step does later.
          await _workflow.send(
            PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
          );
          await _eventuallyInState(
            invoice.id,
            InvoiceWorkflowState.paymentReceived,
          );

          expect(calls.map((c) => c.attempt), [1, 2, 3]);
          expect(calls.map((c) => c.idempotencyKey).toSet(), hasLength(1));
          await _eventuallyNoEvents();
        },
      );

      var failureStateCalls = 0;
      declareTest(
        'moves the element to the failure state when all attempts failed',
        _components(
          _steps(
            signalRetry: const RetryPolicy(
              maxAttempts: 2,
              initialDelay: Duration(milliseconds: 10),
            ),
            signalFailureState: InvoiceWorkflowState.paymentFailed,
            processPayment: (step) async {
              failureStateCalls++;
              throw ApiRequestException(503, 'Payment API not available.');
            },
          ),
        ),
        () async {
          final invoice = await _start(InvoiceWorkflowState.paymentRequested);
          await _workflow.send(
            PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
          );

          await _eventuallyInState(
            invoice.id,
            InvoiceWorkflowState.paymentFailed,
          );
          expect(failureStateCalls, 2);
          await _eventuallyNoEvents();
        },
      );

      var parkedCalls = 0;
      declareTest(
        'parks the signal when all attempts failed and there is no failure state',
        _components(
          _steps(
            signalRetry: const RetryPolicy(
              maxAttempts: 2,
              initialDelay: Duration(milliseconds: 10),
            ),
            processPayment: (step) async {
              parkedCalls++;
              throw ApiRequestException(503, 'Payment API not available.');
            },
          ),
        ),
        () async {
          final invoice = await _start(InvoiceWorkflowState.paymentRequested);
          await _workflow.send(
            PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
          );

          await _eventuallyEvent(WorkflowEventStatus.failed);
          final event = (await _events.readAll()).single;
          expect(event.attempts, 2);
          expect(event.lastError, contains('Payment API not available.'));
          expect(
            (await _read(invoice.id)).state,
            InvoiceWorkflowState.paymentRequested,
          );

          // Parked signals are left alone.
          await Future.delayed(const Duration(milliseconds: 200));
          expect(parkedCalls, 2);
        },
      );
    });
  });

  group('concurrent changes', () {
    declareTest(
      'only writes the fields a step changed',
      _components(
        _steps(
          requestPayment: (step) async {
            // Somebody else edits the invoice while the step is running.
            await _invoices.updateAll(
              filter: $Invoice.$id.equals(step.element.id),
              values: {$Invoice.$recipient: 'Changed Recipient'},
            );
            return _requestPayment(step);
          },
        ),
      ),
      () async {
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );

        final result = await _read(invoice.id);
        expect(result.recipient, 'Changed Recipient');
        expect(result.invoiceFile, 'invoice-${invoice.id}.pdf');
      },
    );

    var conflictCalls = 0;
    declareTest(
      'discards the result when the state was changed in the meantime',
      _components(
        _steps(
          requestPayment: (step) async {
            conflictCalls++;
            await _invoices.updateAll(
              filter: $Invoice.$id.equals(step.element.id),
              values: {$Invoice.$state: InvoiceWorkflowState.paymentFailed},
            );
            return step.element.copyWith(
              state: InvoiceWorkflowState.paymentRequested,
              paymentReference: 'must not be written',
            );
          },
        ),
      ),
      () async {
        final invoice = await _start();
        await _eventually(() => conflictCalls == 1, reason: 'the step to run');
        // Give the service the chance to (wrongly) write or retry.
        await Future.delayed(const Duration(milliseconds: 200));

        final result = await _read(invoice.id);
        expect(result.state, InvoiceWorkflowState.paymentFailed);
        expect(result.paymentReference, isNull);
        expect(conflictCalls, 1);
        await _eventuallyNoEvents();
      },
    );
  });

  final generateRuns = <String, int>{};
  final paymentRuns = <String, int>{};
  final signalRuns = <String, int>{};
  declareTest(
    'runs every step exactly once with multiple instances',
    _components(
      _steps(
        generate: (step) async {
          generateRuns.update(step.element.id, (n) => n + 1, ifAbsent: () => 1);
          await Future.delayed(const Duration(milliseconds: 5));
          return _generate(step);
        },
        requestPayment: (step) async {
          paymentRuns.update(step.element.id, (n) => n + 1, ifAbsent: () => 1);
          await Future.delayed(const Duration(milliseconds: 5));
          return _requestPayment(step);
        },
        processPayment: (step) async {
          signalRuns.update(step.element.id, (n) => n + 1, ifAbsent: () => 1);
          await Future.delayed(const Duration(milliseconds: 5));
          return _processPayment(step);
        },
      ),
      instances: 3,
    ),
    () async {
      final ids = [for (var i = 0; i < 20; i++) (await _start()).id];
      for (final id in ids) {
        await _eventuallyInState(id, InvoiceWorkflowState.paymentRequested);
      }

      // Signals are handled by whichever instance gets to them first.
      for (final id in ids) {
        await _workflow.send(
          PaymentSuccessSignal(invoiceId: id, reference: 'ref-$id'),
        );
      }
      for (final id in ids) {
        await _eventuallyInState(id, InvoiceWorkflowState.paymentReceived);
      }

      expect(generateRuns.keys, unorderedEquals(ids));
      expect(generateRuns.values, everyElement(1));
      expect(paymentRuns.keys, unorderedEquals(ids));
      expect(paymentRuns.values, everyElement(1));
      expect(signalRuns.keys, unorderedEquals(ids));
      expect(signalRuns.values, everyElement(1));
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );

  group('history', () {
    declareTest(
      'records what happened to an element',
      _components(_steps(), history: true),
      () async {
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );
        await _workflow.send(
          PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref-1'),
        );
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );

        final history = await _workflow.history(invoice.id);
        expect(history.map((e) => e.kind), [
          WorkflowHistoryKind.started,
          WorkflowHistoryKind.stepSucceeded,
          WorkflowHistoryKind.stepSucceeded,
          WorkflowHistoryKind.signalReceived,
          WorkflowHistoryKind.stepSucceeded,
        ]);
        expect(history.map((e) => e.step), [
          null,
          'created',
          'generated',
          'PaymentSuccessSignal',
          'PaymentSuccessSignal',
        ]);
        expect(history.map((e) => (e.state, e.newState)), [
          ('created', null),
          ('created', 'generated'),
          ('generated', 'paymentRequested'),
          (null, null),
          ('paymentRequested', 'paymentReceived'),
        ]);

        // The changed values, as an audit of what the steps did.
        expect(history[1].changes, {
          'state': 'generated',
          'invoiceFile': 'invoice-${invoice.id}.pdf',
        });
        expect(history[4].changes, {
          'state': 'paymentReceived',
          'paymentReference': 'ref-1',
        });

        // The signal, and the step that applied it, share their event.
        expect(history[3].signal?['reference'], 'ref-1');
        expect(history[4].eventId, history[3].eventId);
      },
    );

    var paymentCalls = 0;
    declareTest(
      'records failed attempts with their errors and log messages',
      _components(
        _steps(
          requestPayment: (step) async {
            paymentCalls++;
            log.info('Requesting payment, attempt ${step.attempt}.');
            if (paymentCalls < 3) {
              throw ApiRequestException(503, 'Payment API not available.');
            }
            return _requestPayment(step);
          },
        ),
        history: true,
      ),
      () async {
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );

        final attempts = [
          for (final entry in await _workflow.history(invoice.id))
            if (entry.step == 'generated') entry,
        ];
        expect(attempts.map((e) => e.kind), [
          WorkflowHistoryKind.stepFailed,
          WorkflowHistoryKind.stepFailed,
          WorkflowHistoryKind.stepSucceeded,
        ]);
        expect(attempts.map((e) => e.attempt), [1, 2, 3]);
        expect(attempts.map((e) => e.eventId).toSet(), hasLength(1));
        expect(attempts.first.error, contains('Payment API not available.'));
        expect(attempts.first.nextAttemptAt, isNotNull);
        expect(attempts.last.error, isNull);

        final message = jsonDecode(attempts.first.messages.single) as Map;
        expect(message['msg'], 'Requesting payment, attempt 1.');
        expect(message['severity'], 'info');
      },
    );

    declareTest(
      'records the move to the failure state',
      _components(
        _steps(
          retry: const RetryPolicy.none(),
          failureState: InvoiceWorkflowState.paymentFailed,
          requestPayment: (step) async =>
              throw ApiRequestException(503, 'Payment API not available.'),
        ),
        history: true,
      ),
      () async {
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentFailed,
        );

        final last = (await _workflow.history(invoice.id)).last;
        expect(last.kind, WorkflowHistoryKind.stepFailed);
        expect(last.state, 'generated');
        expect(last.newState, 'paymentFailed');
        expect(last.nextAttemptAt, isNull);
      },
    );

    declareTest(
      'records parked events',
      _components(
        _steps(
          retry: const RetryPolicy.none(),
          requestPayment: (step) async =>
              throw ApiRequestException(503, 'Payment API not available.'),
        ),
        history: true,
      ),
      () async {
        final invoice = await _start();
        await _eventuallyEvent(WorkflowEventStatus.failed);

        final history = await _workflow.history(invoice.id);
        expect(history.map((e) => e.kind).skip(2), [
          WorkflowHistoryKind.stepFailed,
          WorkflowHistoryKind.parked,
        ]);
        expect(history.last.error, contains('Payment API not available.'));
      },
    );

    declareTest(
      'records cancelled delayed steps',
      _components(
        _steps(
          extra: [
            OnEnter(
              InvoiceWorkflowState.paymentRequested,
              (step) async => step.element.copyWith(
                state: InvoiceWorkflowState.paymentFailed,
              ),
              name: 'cancel unpaid',
              after: const Duration(seconds: 10),
            ),
          ],
        ),
        history: true,
      ),
      () async {
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );
        await _workflow.send(
          PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
        );
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );

        final cancelled = [
          for (final entry in await _workflow.history(invoice.id))
            if (entry.kind == WorkflowHistoryKind.cancelled) entry,
        ];
        expect(cancelled.single.step, 'cancel unpaid');
        expect(cancelled.single.state, 'paymentRequested');
      },
    );

    declareTest(
      'is not written without a history repository',
      _components(_steps()),
      () async {
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );

        await expectLater(
          _workflow.history(invoice.id),
          throwsA(isA<ApiException>()),
        );
      },
    );
  });

  group('workers', () {
    declareTest(
      'does not run steps on instances that are not workers',
      _components(_steps(), workers: [false]),
      () async {
        final invoice = await _start();
        await _workflow.send(
          PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
        );

        await Future.delayed(const Duration(milliseconds: 300));
        expect((await _read(invoice.id)).state, InvoiceWorkflowState.created);

        // Everything is stored for the workers.
        final events = await _events.readAll();
        expect(
          events.map((e) => e.step),
          unorderedEquals(['created', 'PaymentSuccessSignal']),
        );
      },
    );

    declareTest(
      'leaves the steps to the workers',
      // The first instance (which `Find` returns) is not a worker.
      _components(_steps(), workers: [false, true]),
      () async {
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );
      },
    );
  });

  group('telemetry', () {
    Telemetry telemetry() => Find<Telemetry>().find();

    final stepTraces = <String, String?>{};
    final stepSpans = <String, String?>{};
    InvoiceHandler traced(String name, InvoiceHandler handler) => (step) {
      final span = telemetry().getDefaultTracer().findParentSpan();
      stepTraces[name] = span?.traceId.hexId;
      stepSpans[name] = span is LocalSpan ? span.name : null;
      return handler(step);
    };

    declareTest(
      'runs steps in the trace of the code that caused them',
      _components(
        _steps(
          generate: traced('generate', _generate),
          requestPayment: traced('requestPayment', _requestPayment),
          processPayment: (step) {
            final span = telemetry().getDefaultTracer().findParentSpan();
            stepTraces['payment'] = span?.traceId.hexId;
            return _processPayment(step);
          },
        ),
      ),
      () async {
        late final String startTrace;
        final invoice = await telemetry().trace('create invoice', (span) {
          startTrace = span.traceId.hexId;
          return _start();
        });
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );

        // The steps the start caused, and the steps they caused, belong to
        // the trace of the start.
        expect(stepTraces['generate'], startTrace);
        expect(stepTraces['requestPayment'], startTrace);
        expect(stepSpans['generate'], 'Workflow step created');

        // A signal continues the trace of the request that sent it.
        late final String webhookTrace;
        await telemetry().trace('payment webhook', (span) {
          webhookTrace = span.traceId.hexId;
          return _workflow.send(
            PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
          );
        });
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );
        expect(stepTraces['payment'], webhookTrace);
        expect(webhookTrace, isNot(startTrace));
      },
    );

    var paymentAttempts = 0;
    declareTest(
      'counts steps and signals',
      _components(
        _steps(
          requestPayment: (step) async {
            if (++paymentAttempts == 1) {
              throw ApiRequestException(503, 'Payment API not available.');
            }
            return _requestPayment(step);
          },
        ),
      ),
      () async {
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );
        await _workflow.send(
          PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
        );
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );

        num sample(String metric, Map<String, String> labels) => telemetry()
            .counter(metric)
            .collect()
            .samples
            .singleWhere(
              (s) => labels.entries.every((e) => s.labels[e.key] == e.value),
            )
            .value;

        expect(
          sample('workflow_invoice_steps_total', {
            'step': 'created',
            'outcome': 'succeeded',
          }),
          1,
        );
        expect(
          sample('workflow_invoice_steps_total', {
            'step': 'generated',
            'outcome': 'failed',
          }),
          1,
        );
        expect(
          sample('workflow_invoice_steps_total', {
            'step': 'generated',
            'outcome': 'succeeded',
          }),
          1,
        );
        expect(
          sample('workflow_invoice_signals_total', {
            'signal': 'PaymentSuccessSignal',
          }),
          1,
        );
      },
    );
  });

  group('deadlines', () {
    // `at` takes the time from the element; the tests compute it from a
    // variable, since Invoice has no date field.
    late DateTime deadline;
    var cancelCalls = 0;
    InvoiceStep cancelAtDeadline() => OnEnter(
      InvoiceWorkflowState.paymentRequested,
      (step) async {
        cancelCalls++;
        return step.element.copyWith(state: InvoiceWorkflowState.paymentFailed);
      },
      at: (invoice) => deadline,
    );

    declareTest(
      'runs a step at the time taken from the element',
      _components(_steps(extra: [cancelAtDeadline()])),
      () async {
        cancelCalls = 0;
        deadline = DateTime.timestamp().add(const Duration(milliseconds: 500));
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );

        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentFailed,
        );
        expect(
          DateTime.timestamp().isBefore(deadline),
          isFalse,
          reason: 'not before the deadline',
        );
        expect(cancelCalls, 1);
      },
    );

    declareTest(
      'cancels a step with a time when the element leaves the state',
      _components(_steps(extra: [cancelAtDeadline()]), history: true),
      () async {
        cancelCalls = 0;
        deadline = DateTime.timestamp().add(const Duration(milliseconds: 500));
        final invoice = await _start();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );
        await _workflow.send(
          PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
        );
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );

        await Future.delayed(const Duration(milliseconds: 700));
        expect(cancelCalls, 0);
        final history = await _workflow.history(invoice.id);
        expect(
          history
              .where((e) => e.kind == WorkflowHistoryKind.cancelled)
              .single
              .step,
          'paymentRequested at',
        );
      },
    );

    declareTest(
      'wakes up for a delayed step before the next poll',
      _components(
        _steps(generateAfter: const Duration(milliseconds: 300)),
        pollInterval: const Duration(seconds: 10),
      ),
      () async {
        final invoice = await _start();
        await _eventually(
          () async => (await _read(invoice.id)).invoiceFile != null,
          timeout: const Duration(seconds: 2),
          reason: 'the delayed step to run long before the next poll',
        );
      },
    );

    // A step becomes due while a poll that makes no progress runs (a slow
    // step fails and retries much later): the next poll has to start right
    // away instead of after the poll interval.
    declareTest(
      'runs a step that became due during a poll without waiting for the next',
      _components([
        OnEnter(
          InvoiceWorkflowState.created,
          (step) async {
            await Future.delayed(const Duration(milliseconds: 300));
            throw ApiRequestException(503, 'Generator not available.');
          },
          name: 'slow',
          retry: const RetryPolicy(initialDelay: Duration(minutes: 1)),
        ),
        OnEnter(
          InvoiceWorkflowState.created,
          (step) async => step.element.copyWith(invoiceFile: 'early.pdf'),
          name: 'early',
          after: const Duration(milliseconds: 150),
        ),
      ], pollInterval: const Duration(seconds: 10)),
      () async {
        final invoice = await _start();

        await _eventually(
          () async => (await _read(invoice.id)).invoiceFile == 'early.pdf',
          timeout: const Duration(seconds: 3),
          reason: 'the delayed step to run right after the slow poll',
        );
      },
    );

    test('rejects a step with both a delay and a time', () {
      expect(
        () => WorkflowService<Invoice, InvoiceWorkflowState>(
          steps: [
            OnEnter(
              InvoiceWorkflowState.created,
              (step) async => step.element,
              // ignore: datahub_lints/workflow_step_delay_and_time
              after: const Duration(seconds: 1),
              at: (invoice) => DateTime.timestamp(),
            ),
          ],
        ).validate($Invoice.bean),
        throwsA(isA<ApiError>()),
      );
    });
  });

  group('running steps', () {
    final paymentStarted = Completer<void>();
    final paymentMayFinish = Completer<void>();
    declareTest(
      'shows the worker, a heartbeat and the log of a running step',
      _components(
        _steps(
          requestPayment: (step) async {
            log.info('Calling the payment provider.');
            paymentStarted.complete();
            await paymentMayFinish.future;
            return _requestPayment(step);
          },
        ),
        heartbeatInterval: const Duration(milliseconds: 50),
      ),
      () async {
        addTearDown(() {
          if (!paymentMayFinish.isCompleted) {
            paymentMayFinish.complete();
          }
        });

        final invoice = await _start();
        await paymentStarted.future;

        await _eventually(() async {
          final event = (await _workflow.events(elementId: invoice.id)).single;
          return event.messages.any((m) => m.contains('Calling the payment'));
        }, reason: 'the log line to be flushed');

        final running = (await _workflow.events(elementId: invoice.id)).single;
        expect(running.step, 'generated');
        expect(running.worker, 'worker-0');
        expect(running.startedAt, isNotNull);
        expect(_workflow.isRunning(running), isTrue);
        // A worker that stopped renewing the heartbeat crashed.
        expect(
          _workflow.isRunning(
            running.copyWith(
              heartbeatAt: DateTime.timestamp().subtract(
                const Duration(seconds: 1),
              ),
            ),
          ),
          isFalse,
        );
        final heartbeat = running.heartbeatAt!;
        await _eventually(
          () async => (await _workflow.events(
            elementId: invoice.id,
          )).single.heartbeatAt!.isAfter(heartbeat),
          reason: 'the heartbeat to be renewed',
        );

        // A running event can not be cancelled.
        await expectLater(
          _workflow.cancel(running.id),
          throwsA(
            isA<ApiRequestException>().having((e) => e.statusCode, 'code', 409),
          ),
        );

        paymentMayFinish.complete();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );
      },
    );
  });

  group('administration', () {
    declareTest('describes the workflow', _components(_steps()), () async {
      final description = _workflow.describe();
      expect(description.name, 'Invoice');
      expect(description.stateField, 'state');
      expect(description.writesHistory, isFalse);
      expect(description.steps.map((s) => (s.name, s.kind)), [
        ('created', WorkflowStepKind.enter),
        ('generated', WorkflowStepKind.enter),
        ('PaymentSuccessSignal', WorkflowStepKind.signal),
        ('PaymentFailedSignal', WorkflowStepKind.signal),
      ]);
      expect(description.steps[2].accept, ['paymentRequested']);
      expect(description.steps[2].signalBean, $PaymentSuccessSignal.bean);
      expect(
        description.states,
        unorderedEquals(['created', 'generated', 'paymentRequested']),
      );
    });

    declareTest(
      'reads the history newest first',
      _components(_steps(), history: true),
      () async {
        expect(_workflow.describe().writesHistory, isTrue);

        final invoice = await _start();
        // Started, and the steps of created and generated.
        await _eventually(
          () async => (await _workflow.history(invoice.id)).length == 3,
          reason: 'the history to be written',
        );

        final oldestFirst = await _workflow.history(invoice.id);
        final newestFirst = await _workflow.history(
          invoice.id,
          newestFirst: true,
        );
        expect(
          newestFirst.map((e) => e.id),
          unorderedEquals(oldestFirst.map((e) => e.id)),
        );
        expect(newestFirst.first.kind, WorkflowHistoryKind.stepSucceeded);
        expect(newestFirst.last.kind, WorkflowHistoryKind.started);
        for (var i = 1; i < newestFirst.length; i++) {
          expect(
            newestFirst[i - 1].timestamp.isBefore(newestFirst[i].timestamp),
            isFalse,
          );
        }

        final newest = await _workflow.history(
          invoice.id,
          newestFirst: true,
          limit: 1,
        );
        expect(newest.single.id, newestFirst.first.id);
      },
    );

    var attempts = 0;
    declareTest(
      'retries a parked event',
      _components(
        _steps(
          retry: const RetryPolicy.none(),
          requestPayment: (step) async {
            if (++attempts == 1) {
              throw ApiRequestException(503, 'Payment API not available.');
            }
            return _requestPayment(step);
          },
        ),
        history: true,
      ),
      () async {
        final invoice = await _start();
        await _eventuallyEvent(WorkflowEventStatus.failed);

        final parked = (await _workflow.events(
          status: WorkflowEventStatus.failed,
        )).single;
        expect(parked.elementId, invoice.id);

        await _workflow.retry(parked.id);
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );
        expect(
          (await _workflow.history(invoice.id)).map((e) => e.kind),
          contains(WorkflowHistoryKind.retried),
        );

        // Only parked events can be retried.
        await expectLater(
          _workflow.retry('unknown'),
          throwsA(isA<ApiRequestException>()),
        );
      },
    );

    declareTest(
      'cancels a pending event',
      _components(_steps(generateAfter: const Duration(seconds: 1))),
      () async {
        final invoice = await _start();
        final pending = (await _workflow.events(elementId: invoice.id)).single;
        expect(_workflow.isRunning(pending), isFalse);

        await _workflow.cancel(pending.id);
        expect(await _workflow.events(elementId: invoice.id), isEmpty);

        await Future.delayed(const Duration(milliseconds: 1200));
        expect((await _read(invoice.id)).state, InvoiceWorkflowState.created);
      },
    );

    declareTest('sends a signal from JSON', _components(_steps()), () async {
      final invoice = await _start(InvoiceWorkflowState.paymentRequested);

      await _workflow.sendJson('PaymentSuccessSignal', {
        'invoiceId': invoice.id,
        'reference': 'from-json',
      });
      await _eventuallyInState(
        invoice.id,
        InvoiceWorkflowState.paymentReceived,
      );
      expect((await _read(invoice.id)).paymentReference, 'from-json');

      // The invalid field is named, so that forms can show the error there.
      await expectLater(
        _workflow.sendJson('PaymentSuccessSignal', {'invoiceId': invoice.id}),
        throwsA(
          isA<ApiRequestException>()
              .having((e) => e.statusCode, 'code', 400)
              .having((e) => e.data['fields'], 'fields', contains('reference')),
        ),
      );
      await expectLater(
        _workflow.sendJson('Unknown', {}),
        throwsA(
          isA<ApiRequestException>().having((e) => e.statusCode, 'code', 404),
        ),
      );
    });

    declareTest(
      'sends a signal from JSON only to the given element',
      _components(_steps()),
      () async {
        final invoice = await _start(InvoiceWorkflowState.paymentRequested);
        final other = await _start(InvoiceWorkflowState.paymentRequested);
        final payload = {'invoiceId': invoice.id, 'reference': 'checked'};

        await expectLater(
          _workflow.sendJson(
            'PaymentSuccessSignal',
            payload,
            elementId: other.id,
          ),
          throwsA(
            isA<ApiRequestException>().having((e) => e.statusCode, 'code', 400),
          ),
        );
        expect(await _workflow.events(elementId: invoice.id), isEmpty);

        await _workflow.sendJson(
          'PaymentSuccessSignal',
          payload,
          elementId: invoice.id,
        );
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );
        expect(
          (await _read(other.id)).state,
          isNot(InvoiceWorkflowState.paymentReceived),
        );
      },
    );
  });

  group('worker session', () {
    setUp(_calls.clear);

    final stepActors = <String?>[];
    declareTest(
      'starts elements as the caller and runs the steps as the engine',
      _watchedComponents(
        _steps(
          generate: (step) async {
            stepActors.add(_actor);
            return _generate(step);
          },
        ),
      ),
      () async {
        final invoice = await _as('alice', _start);
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );

        expect(_actors('Invoice', 'create'), {'alice'});
        // The step sees the engine as the only session, and writes as it.
        expect(stepActors, ['engine']);
        expect(_actors('Invoice', 'update'), {'engine'});
        expect(_actors('WorkflowEvent'), {'engine'});
        expect(_actors('WorkflowHistoryEntry'), {'engine'});
      },
    );

    declareTest(
      'does not create elements for callers who may not create them',
      _watchedComponents(_steps()),
      () async {
        await expectLater(
          _as('mallory', _start),
          throwsA(
            isA<ApiRequestException>().having((e) => e.statusCode, 'code', 403),
          ),
        );
        expect(await _events.readAll(), isEmpty);
      },
    );

    declareTest(
      'resumes, sends and reads as the caller',
      _watchedComponents(_steps()),
      () async {
        final invoice = await _invoices.create(
          Invoice(
            recipient: 'Tester',
            invoiceFile: null,
            amount: 123,
            state: InvoiceWorkflowState.paymentRequested,
          ),
        );
        _calls.clear();

        await _as('alice', () => _workflow.resume(invoice.id));
        expect(_actors('Invoice', 'read'), {'alice'});

        await _as(
          'alice',
          () => _workflow.send(
            PaymentSuccessSignal(invoiceId: invoice.id, reference: 'ref'),
          ),
        );
        expect(_actors('WorkflowEvent', 'create'), {'alice'});
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentReceived,
        );

        _calls.clear();
        await _as('alice', () => _workflow.events());
        await _as('alice', () => _workflow.history(invoice.id));
        expect(_actors('WorkflowEvent'), {'alice'});
        expect(_actors('WorkflowHistoryEntry'), {'alice'});
      },
    );

    var attempts = 0;
    declareTest(
      'lets a caller retry and cancel steps it may not run itself',
      _watchedComponents(
        _steps(
          retry: const RetryPolicy.none(),
          generateAfter: const Duration(hours: 1),
          requestPayment: (step) async {
            if (++attempts == 1) {
              throw ApiRequestException(503, 'Payment API not available.');
            }
            return _requestPayment(step);
          },
        ),
      ),
      () async {
        // The clerk may not write invoices, the step does it.
        final invoice = await _start(InvoiceWorkflowState.generated);
        await _eventuallyEvent(WorkflowEventStatus.failed);
        final parked = (await _workflow.events(elementId: invoice.id)).single;
        _calls.clear();

        await _as('clerk', () => _workflow.retry(parked.id));
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );
        expect(_actors('WorkflowEvent', 'read'), contains('clerk'));
        expect(_actors('WorkflowEvent', 'update'), contains('clerk'));
        expect(_actors('Invoice', 'update'), {'engine'});
        expect(_actors('WorkflowHistoryEntry', 'create'), {'engine'});

        final waiting = await _start();
        final pending = (await _workflow.events(elementId: waiting.id)).single;
        _calls.clear();
        await _as('clerk', () => _workflow.cancel(pending.id));
        expect(_actors('WorkflowEvent', 'read'), {'clerk'});
        expect(_actors('WorkflowEvent', 'delete'), {'clerk'});
        expect(_actors('WorkflowHistoryEntry', 'create'), {'engine'});
        expect(await _workflow.events(elementId: waiting.id), isEmpty);
      },
    );

    final paymentStarted = Completer<void>();
    final paymentMayFinish = Completer<void>();
    declareTest(
      'renews the heartbeat as the engine',
      _watchedComponents(
        _steps(
          requestPayment: (step) async {
            paymentStarted.complete();
            await paymentMayFinish.future;
            return _requestPayment(step);
          },
        ),
        heartbeatInterval: const Duration(milliseconds: 20),
      ),
      () async {
        addTearDown(() {
          if (!paymentMayFinish.isCompleted) {
            paymentMayFinish.complete();
          }
        });
        final invoice = await _as('alice', _start);
        await paymentStarted.future;

        final updates = _calls.where(
          (call) => call.$1 == 'WorkflowEvent' && call.$2 == 'update',
        );
        final before = updates.length;
        await _eventually(
          () => updates.length >= before + 3,
          reason: 'heartbeats',
        );
        expect(_actors('WorkflowEvent', 'update'), {'engine'});

        paymentMayFinish.complete();
        await _eventuallyInState(
          invoice.id,
          InvoiceWorkflowState.paymentRequested,
        );
      },
    );
  });
}
