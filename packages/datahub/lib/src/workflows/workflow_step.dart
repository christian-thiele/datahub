import 'package:datahub/data.dart';

import 'retry_policy.dart';
import 'workflow_signal.dart';
import 'workflow_step_context.dart';

/// A unit of work of a workflow (see `WorkflowService`).
///
/// A step's handler returns the element it has changed. The workflow service
/// writes back **only the fields that differ** from the element the handler
/// received, and only while the element is still in the state it was read in.
///
/// When the handler throws, the step is retried according to [retry]. When all
/// attempts failed, the element is moved to [failureState] if set, or the
/// event is parked otherwise (see `WorkflowEvent`).
sealed class WorkflowStep<T extends DataObject, TState extends Enum> {
  final String? _name;

  final RetryPolicy retry;

  /// State an element is moved to when all attempts failed.
  final TState? failureState;

  /// Maximum time the handler may run.
  ///
  /// The element stays locked while a handler runs, so this protects from
  /// elements that are locked forever by a hanging handler. Dart can not
  /// cancel a running future, so a timed out handler may still finish in the
  /// background, its result is discarded.
  final Duration timeout;

  const WorkflowStep({
    String? name,
    this.retry = const RetryPolicy(),
    this.failureState,
    this.timeout = const Duration(minutes: 5),
  }) : _name = name;

  /// Identifies the step in logs and in the stored events of the workflow.
  ///
  /// Defaults to a name derived from what triggers the step. Pending events of
  /// a step that was renamed or removed can not be handled anymore and are
  /// parked.
  String get name => _name ?? _defaultName;

  String get _defaultName;
}

/// Runs when an element enters [state], or [after] that if the element is
/// still in [state] then.
///
/// Leaving [state] cancels the steps that did not run yet, so a delayed step
/// is a timeout:
///
/// ```dart
/// OnEnter(InvoiceState.paymentRequested, cancelInvoice,
///     after: Duration(days: 14)),
/// ```
///
/// Several steps can run for the same state, typically with different delays.
/// Steps for the same state and delay need different names.
///
/// The handler may leave the element in [state], the step does not run again
/// for it until the element enters [state] again.
final class OnEnter<T extends DataObject, TState extends Enum>
    extends WorkflowStep<T, TState> {
  final TState state;

  final Duration after;

  final Future<T> Function(StepContext<T> context) handle;

  const OnEnter(
    this.state,
    this.handle, {
    super.name,
    this.after = Duration.zero,
    super.retry,
    super.failureState,
    super.timeout,
  });

  @override
  String get _defaultName =>
      after == Duration.zero ? state.name : '${state.name} after $after';
}

/// Runs when a signal of type [TSignal] was sent for an element.
///
/// [target] tells which element (by id) a signal is meant for. The step runs as
/// soon as that element is in one of the [accept] states and not busy. Until
/// then the signal waits, which covers signals that arrive early or while
/// another step runs for the element. A signal that was not applied within
/// [expireAfter] is parked and logged as error.
///
/// A signal is applied once, but may be duplicated by its sender. The [accept]
/// states are what protects from that: the handler **SHOULD** move the element
/// out of them, otherwise it has to be idempotent.
///
/// ```dart
/// OnSignal($PaymentSignal.bean,
///     accept: [InvoiceState.paymentRequested],
///     target: (signal) => signal.invoiceId,
///     handle: (step) async =>
///         step.element.copyWith(state: InvoiceState.paid)),
/// ```
final class OnSignal<
  T extends DataObject,
  TState extends Enum,
  TSignal extends DataObject
>
    extends WorkflowStep<T, TState> {
  /// The bean of the signal, which is used to store and restore it.
  /// It also determines [TSignal], which has to implement
  /// `WorkflowSignal<T>` (see [isSignalForElement]).
  final DataBean<TSignal> signalBean;

  /// States in which the step accepts its signal. Must not be empty.
  final List<TState> accept;

  /// The id of the element a signal is meant for.
  final Object Function(TSignal signal) target;

  /// Time after which a signal that was not applied is given up.
  final Duration expireAfter;

  final Future<T> Function(SignalStepContext<T, TSignal> context) handle;

  const OnSignal(
    this.signalBean, {
    required this.accept,
    required this.target,
    required this.handle,
    super.name,
    this.expireAfter = const Duration(days: 1),
    super.retry,
    super.failureState,
    super.timeout,
  });

  @override
  String get _defaultName => signalBean.name;

  /// Whether [TSignal] is declared as signal for the element type [T].
  ///
  /// A step for any other type could never be reached with
  /// `Workflow<T>.send`. `WorkflowService.validate` rejects it.
  bool get isSignalForElement => <TSignal>[] is List<WorkflowSignal<T>>;

  /// Whether [signal] is of the type handled by this step.
  bool accepts(Object signal) => signal is TSignal;

  /// Serializes [signal] for storage.
  Map<String, dynamic> encode(Object signal) => (signal as TSignal).toJson();

  /// The id of the element [signal] is meant for.
  Object targetOf(Object signal) => target(signal as TSignal);

  /// Restores the signal from [payload] and runs the handler for it.
  Future<T> run(
    Map<String, dynamic> payload, {
    required T element,
    required int attempt,
    required String idempotencyKey,
    required Future<void> lockExpired,
  }) => handle(
    SignalStepContext<T, TSignal>(
      element: element,
      attempt: attempt,
      idempotencyKey: idempotencyKey,
      lockExpired: lockExpired,
      signal: signalBean.fromJson(payload),
    ),
  );
}
