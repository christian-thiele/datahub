import 'dart:async';

import 'package:datahub/telemetry.dart';

import 'abstract/redis_exception.dart';
import 'protocol/command_rules.dart';
import 'protocol/resp_parser.dart';

/// Metrics and traces of a [RedisService].
///
/// Keys, channels, patterns and values are never used as metric labels, span
/// names or span attributes, since they are unbounded and may contain
/// sensitive data. Only command names, which are a small closed set, and the
/// connection target are reported.
///
/// All methods do nothing for the parts that are disabled, so call sites do
/// not need to check [metricsEnabled] or [tracingEnabled].
class RedisTelemetry {
  /// Does nothing, used where no telemetry is configured.
  static const disabled = RedisTelemetry._disabled();

  static const _commandStatus = ['ok', 'error'];
  static const _errorKinds = [
    'server',
    'connection',
    'protocol',
    'timeout',
    'other',
  ];
  static const _closeKinds = [
    'local',
    'server',
    'error',
    'protocol',
    'timeout',
  ];

  final Telemetry? _telemetry;
  final bool tracingEnabled;
  final String host;
  final int port;
  final _Metrics? _metrics;

  bool get metricsEnabled => _metrics != null;

  const RedisTelemetry._disabled()
    : _telemetry = null,
      tracingEnabled = false,
      host = '',
      port = 0,
      _metrics = null;

  RedisTelemetry({
    required Telemetry telemetry,
    required String metricPrefix,
    required bool enableMetrics,
    required bool enableTracing,
    required this.host,
    required this.port,
  }) : _telemetry = telemetry,
       tracingEnabled = enableTracing,
       _metrics = enableMetrics ? _Metrics(telemetry, metricPrefix) : null;

  // --- commands ---

  /// Runs [delegate], which sends the command [name] on a connection to
  /// [database], and records its duration and outcome.
  Future<T> command<T>(
    String? name,
    int database,
    Future<T> Function() delegate,
  ) {
    final metrics = _metrics;
    final clazz = commandClass(name);
    final watch = Stopwatch()..start();

    Future<T> run(LocalSpan? span) async {
      try {
        final result = await delegate();
        metrics?.commands.inc({'command_class': clazz, 'status': 'ok'});
        return result;
      } catch (e) {
        metrics?.commands.inc({'command_class': clazz, 'status': 'error'});
        if (e is TimeoutException) {
          metrics?.commandTimeouts.inc();
        }
        error(e);
        span?.setAttribute('error.type', switch (e) {
          RedisServerException(:final code) => code,
          _ => e.runtimeType.toString(),
        });
        if (e is RedisServerException) {
          span?.setAttribute('db.response.status_code', e.code);
          if (e.code == 'NOSCRIPT') {
            // RedisCommands.eval falls back to sending the script source
            metrics?.scriptCacheMisses.inc();
          }
        }
        rethrow;
      } finally {
        metrics?.commandDuration.observeDuration(watch.elapsed, {
          'command_class': clazz,
        });
      }
    }

    // span names according to the semantic conventions for database client
    // spans: the operation, or the database system if it is unknown
    return _span(
      name ?? 'redis',
      run,
      type: SpanType.client,
      attributes: {
        'db.system.name': 'redis',
        'db.operation.name': ?name,
        'db.namespace': database.toString(),
        'server.address': host,
        'server.port': port,
      },
    );
  }

  /// Runs [delegate] of a transaction of [commandCount] commands.
  Future<bool> transaction(
    int database,
    int commandCount,
    Future<bool> Function() delegate,
  ) {
    return _span(
      'MULTI',
      (span) async {
        final committed = await delegate();
        span?.setAttribute('datahub.redis.transaction.aborted', !committed);
        return committed;
      },
      type: SpanType.client,
      attributes: {
        'db.system.name': 'redis',
        'db.operation.name': 'MULTI',
        'db.operation.batch.size': commandCount,
        'db.namespace': database.toString(),
        'server.address': host,
        'server.port': port,
      },
    );
  }

  /// Traces [delegate] as span [name], if tracing is enabled.
  Future<T> traced<T>(
    String name,
    Future<T> Function() delegate, {
    Map<String, dynamic> attributes = const {},
    SpanType type = SpanType.internal,
  }) => _span(name, (_) => delegate(), attributes: attributes, type: type);

  Future<T> _span<T>(
    String name,
    Future<T> Function(LocalSpan? span) delegate, {
    Map<String, dynamic> attributes = const {},
    SpanType type = SpanType.internal,
  }) async {
    if (!tracingEnabled || _telemetry == null) {
      return await delegate(null);
    }
    return await _telemetry.trace(
      name,
      (span) => delegate(span),
      type: type,
      attributes: attributes,
    );
  }

  /// Counts [e] in the error metric, by its kind.
  void error(Object e) => _metrics?.errors.inc({'kind': errorKind(e)});

  /// The low cardinality kind of [e], see `errors_total`.
  static String errorKind(Object e) => switch (e) {
    RedisServerException() => 'server',
    TimeoutException() => 'timeout',
    RedisConnectionException(cause: RespProtocolException()) => 'protocol',
    RedisConnectionException() => 'connection',
    _ => 'other',
  };

  // --- connections and pool ---

  void connectionOpened() => _metrics?.connectionsOpened.inc();

  /// [kind] is one of `local`, `server`, `error`, `protocol` or `timeout`.
  void connectionClosed(String kind) =>
      _metrics?.connectionsClosed.inc({'reason': kind});

  void healthCheckFailed() => _metrics?.healthCheckFailures.inc();

  void poolRejected() => _metrics?.poolRejected.inc();

  /// Measures the time [delegate] needs to get a connection from the pool.
  Future<T> poolWait<T>(Future<T> Function() delegate) {
    final metrics = _metrics;
    if (metrics == null && !tracingEnabled) {
      return delegate();
    }
    return _span('Redis Pool Take', (_) async {
      final watch = Stopwatch()..start();
      try {
        return await delegate();
      } finally {
        metrics?.poolWait.observeDuration(watch.elapsed);
      }
    });
  }

  void poolSize({
    required int target,
    required int total,
    required int available,
  }) {
    _metrics?.poolTarget.set(target);
    _metrics?.poolTotal.set(total);
    _metrics?.poolAvailable.set(available);
    _metrics?.poolInUse.set(total - available);
  }

  // --- locks ---

  void lockAcquired(Duration waited) {
    _metrics?.locksAcquired.inc();
    _metrics?.lockWait.observeDuration(waited);
  }

  void lockContended() => _metrics?.locksContended.inc();

  void lockReleased(Duration held) => _metrics?.lockHold.observeDuration(held);

  void locksHeld(int count) => _metrics?.locksHeld.set(count);

  void lockRenewalFailed() => _metrics?.lockRenewalFailures.inc();

  void lockLost() => _metrics?.locksLost.inc();

  // --- pub/sub ---

  void subscriberConnected(bool connected) =>
      _metrics?.subscriberConnected.set(connected ? 1 : 0);

  void subscriptions(int count) => _metrics?.subscriptions.set(count);

  void subscriberReconnecting() => _metrics?.subscriberReconnects.inc();

  void messageReceived() => _metrics?.messagesReceived.inc();

  // --- scripts ---

  void scriptCacheMiss() => _metrics?.scriptCacheMisses.inc();
}

class _Metrics {
  final CounterMetric commands;
  final HistogramMetric commandDuration;
  final CounterMetric commandTimeouts;
  final CounterMetric errors;
  final GaugeMetric poolTarget;
  final GaugeMetric poolTotal;
  final GaugeMetric poolAvailable;
  final GaugeMetric poolInUse;
  final HistogramMetric poolWait;
  final CounterMetric poolRejected;
  final CounterMetric connectionsOpened;
  final CounterMetric connectionsClosed;
  final CounterMetric healthCheckFailures;
  final CounterMetric locksAcquired;
  final CounterMetric locksContended;
  final HistogramMetric lockWait;
  final HistogramMetric lockHold;
  final GaugeMetric locksHeld;
  final CounterMetric lockRenewalFailures;
  final CounterMetric locksLost;
  final GaugeMetric subscriberConnected;
  final GaugeMetric subscriptions;
  final CounterMetric subscriberReconnects;
  final CounterMetric messagesReceived;
  final CounterMetric scriptCacheMisses;

  _Metrics(Telemetry t, String p)
    : commands = t.counter(
        '${p}_commands_total',
        help: 'Commands sent to the Redis server.',
        labels: {
          'command_class': commandClasses,
          'status': RedisTelemetry._commandStatus,
        },
      ),
      commandDuration = t.exponentialHistogram(
        '${p}_command_duration_seconds',
        help: 'Time from sending a command until its reply was processed.',
        start: 0.0005,
        factor: 2,
        count: 14,
        labels: {'command_class': commandClasses},
      ),
      commandTimeouts = t.counter(
        '${p}_command_timeouts_total',
        help: 'Commands that timed out, which closes their connection.',
      ),
      errors = t.counter(
        '${p}_errors_total',
        help: 'Failed Redis operations by kind of error.',
        labels: {'kind': RedisTelemetry._errorKinds},
      ),
      poolTarget = t.gauge(
        '${p}_pool_size_target',
        help: 'Target number of pooled connections.',
      ),
      poolTotal = t.gauge(
        '${p}_pool_size_total',
        help: 'Number of open pooled connections.',
      ),
      poolAvailable = t.gauge(
        '${p}_pool_size_available',
        help: 'Number of idle pooled connections.',
      ),
      poolInUse = t.gauge(
        '${p}_pool_size_in_use',
        help: 'Number of pooled connections currently in use.',
      ),
      poolWait = t.exponentialHistogram(
        '${p}_pool_wait_seconds',
        help: 'Time spent waiting for a connection from the pool.',
        start: 0.0005,
        factor: 2,
        count: 14,
      ),
      poolRejected = t.counter(
        '${p}_pool_rejected_total',
        help: 'Requests rejected because the pool queue limit was reached.',
      ),
      connectionsOpened = t.counter(
        '${p}_connections_opened_total',
        help: 'Connections opened to the Redis server.',
      ),
      connectionsClosed = t.counter(
        '${p}_connections_closed_total',
        help: 'Connections closed, by reason.',
        labels: {'reason': RedisTelemetry._closeKinds},
      ),
      healthCheckFailures = t.counter(
        '${p}_health_check_failures_total',
        help: 'Pooled connections that failed their health check.',
      ),
      locksAcquired = t.counter(
        '${p}_locks_acquired_total',
        help: 'Locks acquired.',
      ),
      locksContended = t.counter(
        '${p}_locks_contended_total',
        help: 'Lock acquisitions that found the lock held by someone else.',
      ),
      lockWait = t.exponentialHistogram(
        '${p}_lock_wait_seconds',
        help: 'Time spent acquiring a lock.',
        start: 0.001,
        factor: 4,
        count: 10,
      ),
      lockHold = t.exponentialHistogram(
        '${p}_lock_hold_seconds',
        help: 'Time locks were held before they were released or lost.',
        start: 0.1,
        factor: 4,
        count: 10,
      ),
      locksHeld = t.gauge(
        '${p}_locks_held',
        help: 'Locks currently held by this service.',
      ),
      lockRenewalFailures = t.counter(
        '${p}_lock_renewal_failures_total',
        help: 'Failed attempts to renew the lease of a lock.',
      ),
      locksLost = t.counter(
        '${p}_locks_lost_total',
        help: 'Locks that expired or were taken over before being released.',
      ),
      subscriberConnected = t.gauge(
        '${p}_subscriber_connected',
        help: '1 while the Pub/Sub connection is established, otherwise 0.',
      ),
      subscriptions = t.gauge(
        '${p}_subscriptions',
        help: 'Subscribed channels and patterns.',
      ),
      subscriberReconnects = t.counter(
        '${p}_subscriber_reconnects_total',
        help: 'Times the Pub/Sub connection was lost and re-established.',
      ),
      messagesReceived = t.counter(
        '${p}_pubsub_messages_received_total',
        help: 'Pub/Sub messages received.',
      ),
      scriptCacheMisses = t.counter(
        '${p}_script_cache_misses_total',
        help:
            'Script invocations that had to send the script source (NOSCRIPT).',
      );
}
