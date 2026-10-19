import 'package:datahub/data.dart';

import 'workflow.dart';

/// What a step handler knows about the execution it is part of.
class const StepContext<T extends DataObject>({
  /// The element as it was read while holding its lock.
  required final T element,

  /// Number of this attempt, starting at 1.
  required final int attempt,

  /// Identifies the event the step handles.
  ///
  /// It stays the same for all attempts, so it is meant to be used as
  /// idempotency key for calls to external systems. A step may run more than
  /// once for the same event (when it fails, or when the process crashes
  /// before the result is persisted), so these calls **MUST** be idempotent.
  required final String idempotencyKey,

  /// Completes when the lock protecting [element] expired.
  ///
  /// The step result is discarded from then on, so long running handlers
  /// **SHOULD** stop their work when this completes.
  required final Future<void> lockExpired,

  /// The workflow the step belongs to, for example to start elements or send
  /// signals from a step. (A workflow service can not `Find` itself, so its
  /// steps can not look it up.)
  required final Workflow<T> workflow,
});

/// The context of an `OnSignal` step.
class const SignalStepContext<
  T extends DataObject,
  TSignal extends DataObject
>({
  required super.element,
  required super.attempt,
  required super.idempotencyKey,
  required super.lockExpired,
  required super.workflow,
  required final TSignal signal,
}) extends StepContext<T>;
