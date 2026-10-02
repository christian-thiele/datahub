import 'dart:math' as math;

/// Describes how often and how fast a failed step is retried.
class RetryPolicy {
  /// Total number of attempts including the first one.
  final int maxAttempts;

  /// Delay before the second attempt.
  final Duration initialDelay;

  /// Factor the delay grows with after every further failed attempt.
  final double backoffFactor;

  /// Upper bound of the delay between two attempts.
  final Duration maxDelay;

  const RetryPolicy({
    this.maxAttempts = 5,
    this.initialDelay = const Duration(seconds: 5),
    this.backoffFactor = 2.0,
    this.maxDelay = const Duration(minutes: 10),
  }) : assert(maxAttempts >= 1, 'maxAttempts must be at least 1.'),
       assert(backoffFactor >= 1, 'backoffFactor must be at least 1.');

  /// Never retry, the first failure is final.
  const RetryPolicy.none() : this(maxAttempts: 1);

  /// Whether another attempt is allowed after [failedAttempts] failures.
  bool allowsRetryAfter(int failedAttempts) => failedAttempts < maxAttempts;

  /// The time to wait after the [failedAttempts]th failure.
  Duration delayAfter(int failedAttempts) {
    final factor = math.pow(backoffFactor, math.max(0, failedAttempts - 1));
    final micros = initialDelay.inMicroseconds * factor;
    if (micros >= maxDelay.inMicroseconds) {
      return maxDelay;
    }
    return Duration(microseconds: micros.round());
  }
}
