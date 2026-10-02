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
          pollInterval: Config.value(const Duration(milliseconds: 20)),
          worker: Config.value(worker),
        ),
      ],
    ),
];

DataRepository<Invoice> get _invoices => Find<DataRepository<Invoice>>().find();

DataRepository<WorkflowEvent> get _events =>
    Find<DataRepository<WorkflowEvent>>().find();

Workflow<Invoice> get _workflow => Find<Workflow<Invoice>>().find();

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
        expect(message['severity'], 'INFO');
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
          sample('workflow_invoice_steps', {
            'step': 'created',
            'outcome': 'succeeded',
          }),
          1,
        );
        expect(
          sample('workflow_invoice_steps', {
            'step': 'generated',
            'outcome': 'failed',
          }),
          1,
        );
        expect(
          sample('workflow_invoice_steps', {
            'step': 'generated',
            'outcome': 'succeeded',
          }),
          1,
        );
        expect(
          sample('workflow_invoice_signals', {
            'signal': 'PaymentSuccessSignal',
          }),
          1,
        );
      },
    );
  });
}
