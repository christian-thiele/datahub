import 'dart:async';

import 'package:datahub/telemetry.dart';
import 'package:postgres/postgres.dart' as pg;

/// Metrics and traces of a [PostgresqlService].
///
/// Queries are traced as spans of kind client according to the semantic
/// conventions for database client spans, named after the operation (e.g.
/// `SELECT`). The query text is only added if it does not contain values
/// (parameterized queries) or if statements are logged.
///
/// All methods do nothing for the parts that are disabled, so call sites do
/// not need to check [metricsEnabled] or [tracingEnabled].
class PostgresqlTelemetry {
  /// Does nothing, used where no telemetry is configured.
  static const disabled = PostgresqlTelemetry._disabled();

  static const _status = ['ok', 'error'];
  static final _operation = RegExp(r'^\s*([A-Za-z]+)');

  final Telemetry? _telemetry;
  final bool tracingEnabled;
  final Map<String, Object> _attributes;
  final _Metrics? _metrics;

  bool get metricsEnabled => _metrics != null;

  const PostgresqlTelemetry._disabled()
    : _telemetry = null,
      tracingEnabled = false,
      _attributes = const {},
      _metrics = null;

  PostgresqlTelemetry({
    required Telemetry telemetry,
    required String metricPrefix,
    required bool enableMetrics,
    required bool enableTracing,
    required String host,
    required int port,
    required String database,
  }) : _telemetry = telemetry,
       tracingEnabled = enableTracing,
       _attributes = {
         'db.system.name': 'postgresql',
         'db.namespace': database,
         'server.address': host,
         'server.port': port,
       },
       _metrics = enableMetrics ? _Metrics(telemetry, metricPrefix) : null;

  /// Runs [delegate], which executes [query], and records its duration and
  /// outcome. The query text is added to the span if [includeText] is true.
  Future<T> query<T>(
    String query,
    Future<T> Function() delegate, {
    required bool includeText,
  }) {
    final metrics = _metrics;
    final operation = _operation.firstMatch(query)?[1]?.toUpperCase();
    final watch = Stopwatch()..start();

    Future<T> run(LocalSpan? span) async {
      try {
        final result = await delegate();
        metrics?.queries.inc({'status': 'ok'});
        return result;
      } catch (e) {
        metrics?.queries.inc({'status': 'error'});
        if (e is pg.ServerException && e.code != null) {
          span?.setAttribute('db.response.status_code', e.code!);
          span?.setAttribute('error.type', e.code!);
        } else {
          span?.setAttribute('error.type', e.runtimeType.toString());
        }
        rethrow;
      } finally {
        metrics?.queryDuration.observeDuration(watch.elapsed);
      }
    }

    return _span(
      operation ?? 'postgresql',
      run,
      type: SpanType.client,
      attributes: {
        ..._attributes,
        'db.operation.name': ?operation,
        if (includeText) 'db.query.text': query,
      },
    );
  }

  /// Runs [delegate] of a transaction.
  Future<T> transaction<T>(Future<T> Function() delegate) => _span(
    'postgresql transaction',
    (_) => delegate(),
    attributes: _attributes,
  );

  /// Measures the time [delegate] needs to get a connection from the pool.
  Future<T> poolWait<T>(Future<T> Function() delegate) async {
    final metrics = _metrics;
    if (metrics == null) {
      return await delegate();
    }

    final watch = Stopwatch()..start();
    try {
      return await delegate();
    } finally {
      metrics.poolWait.observeDuration(watch.elapsed);
    }
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

  Future<T> _span<T>(
    String name,
    Future<T> Function(LocalSpan? span) delegate, {
    Map<String, Object?> attributes = const {},
    SpanType type = SpanType.internal,
  }) async {
    final telemetry = _telemetry;
    if (!tracingEnabled || telemetry == null) {
      return await delegate(null);
    }
    return await telemetry.trace(
      name,
      delegate,
      type: type,
      attributes: attributes,
    );
  }
}

class _Metrics {
  final CounterMetric queries;
  final HistogramMetric queryDuration;
  final GaugeMetric poolTarget;
  final GaugeMetric poolTotal;
  final GaugeMetric poolAvailable;
  final GaugeMetric poolInUse;
  final HistogramMetric poolWait;

  _Metrics(Telemetry t, String p)
    : queries = t.counter(
        '${p}_queries_total',
        help: 'Queries sent to the PostgreSQL server.',
        labels: {'status': PostgresqlTelemetry._status},
      ),
      queryDuration = t.histogram(
        '${p}_query_duration_seconds',
        help: 'Time from sending a query until its result was received.',
        buckets: HistogramMetric.defaultDurationBuckets,
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
      poolWait = t.histogram(
        '${p}_pool_wait_seconds',
        help: 'Time spent waiting for a connection from the pool.',
        buckets: HistogramMetric.defaultDurationBuckets,
      );
}
