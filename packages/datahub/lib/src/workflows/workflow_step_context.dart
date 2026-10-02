import 'package:datahub/data.dart';

/// What a step handler knows about the execution it is part of.
class StepContext<T extends DataObject> {
  /// The element as it was read while holding its lock.
  final T element;

  /// Number of this attempt, starting at 1.
  final int attempt;

  /// Identifies the event the step handles.
  ///
  /// It stays the same for all attempts, so it is meant to be used as
  /// idempotency key for calls to external systems. A step may run more than
  /// once for the same event (when it fails, or when the process crashes
  /// before the result is persisted), so these calls **MUST** be idempotent.
  final String idempotencyKey;

  /// Completes when the lock protecting [element] expired.
  ///
  /// The step result is discarded from then on, so long running handlers
  /// **SHOULD** stop their work when this completes.
  final Future<void> lockExpired;

  const StepContext({
    required this.element,
    required this.attempt,
    required this.idempotencyKey,
    required this.lockExpired,
  });
}

/// The context of an `OnSignal` step.
class SignalStepContext<T extends DataObject, TSignal extends DataObject>
    extends StepContext<T> {
  final TSignal signal;

  const SignalStepContext({
    required super.element,
    required super.attempt,
    required super.idempotencyKey,
    required super.lockExpired,
    required this.signal,
  });
}
