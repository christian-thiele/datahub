---
title: Telemetry
index: 107
---

DataHub's telemetry system covers **logs**, **metrics** and **distributed traces** in a single, cohesive service: `TelemetryService`. It integrates seamlessly with Prometheus for metrics scraping and OpenTelemetry for trace export, and with the Dart developer timeline for local debugging.

## Setup

Add `TelemetryService` to your component list. It is always automatically added by `ApplicationHost` to an internal scope, but you can also add it explicitly to customise its config path:

```dart
runApp([
  TelemetryService(),        // uses default config paths under 'telemetry.*'
  MyService(),
]);
```

The `Telemetry` interface is then available via `Find<Telemetry>()` from any service.

---

## Logging

### Global log helper

The `log` global provides a zero-boilerplate way to write log messages from anywhere inside a running context:

```dart
import 'package:datahub/telemetry.dart';

log.trace('Verbose detail');
log.debug('Debug info');
log.info('User logged in', labels: {'userId': user.id});
log.warn('Cache miss', labels: {'key': cacheKey});
log.error('Failed to send email', error: e, stack: stack);
log.fatal('Unrecoverable error, shutting down');
```

`log(...)` (called directly) is an alias for `log.debug(...)`.

Labels are key/value pairs that travel with the log message and are output in the configured format.

### Log Levels

| Level | Description |
|-------|-------------|
| `trace` | Extremely verbose, typically disabled in production |
| `debug` | Development diagnostics |
| `info` | Normal operational events |
| `warning` | Non-critical issues |
| `error` | Errors that need attention |
| `fatal` | Unrecoverable errors |

### Output Formats

Configure the stdout output format:

```yaml
telemetry:
  logLevel: info         # Minimum level (default: debug)
  logStdoutFormat: logfmt  # logfmt (default) or json
```

**logfmt** (structured key=value): readable in terminals  
**json**: machine-parseable, preferred for log aggregation pipelines

---

## Metrics

Metrics are defined once and then incremented or observed from anywhere in the application. Because the `Telemetry` service deduplicates by name, the same metric handle is returned when you call a definition method with the same name more than once.

### Counter

Monotonically increasing. Suitable for "total number of X" values.

```dart
final requestCount = telemetry.counter(
  'http_requests_total',
  labels: {'method': ['GET', 'POST'], 'status': ['200', '400', '500']},
  help: 'Total HTTP requests served',
);

// Increment without labels
requestCount.increment();

// Increment with labels
requestCount.increment(labels: {'method': 'GET', 'status': '200'});
```

### Gauge

Can increase or decrease. Use for current values such as queue depth or active connections.

```dart
final activeConns = telemetry.gauge('http_active_connections');
activeConns.set(activeConns.value + 1);

// Measure duration automatically
final result = await activeConns.measureDuration(() async {
  return await expensiveOperation();
});
```

### Histogram

Tracks the distribution of values over configurable buckets.

```dart
// Linear buckets: 0, 0.05, 0.10 … 0.50s
final latency = telemetry.linearHistogram(
  'http_request_duration_seconds',
  start: 0,
  width: 0.05,
  count: 10,
  help: 'Request latency in seconds',
);

latency.record(elapsed.inMilliseconds / 1000);

// Exponential buckets: 1, 2, 4, 8 …
final sizes = telemetry.exponentialHistogram(
  'request_payload_bytes',
  start: 1,
  factor: 2,
  count: 12,
);
```

### Prometheus Endpoint

Enable the built-in Prometheus scrape endpoint:

```yaml
telemetry:
  prometheusExporter:
    enabled: true
    port: 9090          # default
    path: /metrics      # default
    address: null       # null = all interfaces
```

The endpoint serves the [Prometheus text-based format](https://prometheus.io/docs/instrumenting/exposition_formats/).

### Custom Collectors

For metrics that come from external sources (a database, an OS counter, etc.) register a custom collector:

```dart
class DbConnectionCollector extends SyncMetricCollector {
  final GaugeMetric _gauge = GaugeMetric('db_pool_connections');

  @override
  SampleGroup collect() {
    _gauge.set(pool.activeConnections);
    return _gauge.collect();
  }
}

// In service initialize():
find(service.telemetry).registerCollector(DbConnectionCollector());
```

---

## Distributed Tracing

DataHub implements distributed tracing following the [OpenTelemetry](https://opentelemetry.io/) model. Spans are propagated through Dart zones so nested calls automatically inherit the current span.

### Basic Tracing

```dart
final result = await telemetry.trace(
  'database_query',
  (span) async {
    span.addEvent('executing_sql');
    final rows = await connection.execute(sql);
    span.setAttributeValue('db.row_count', rows.length);
    return rows;
  },
  type: SpanType.client,
  attributes: {'db.system': 'postgresql'},
);
```

### Span Types

| Type | Description |
|------|-------------|
| `SpanType.internal` | Internal operation (default) |
| `SpanType.server` | Serving an inbound request |
| `SpanType.client` | Outbound call to a dependency |
| `SpanType.producer` | Publishing a message |
| `SpanType.consumer` | Consuming a message |

`ApiService` automatically wraps each request in a server span named after the route pattern.

### Events and Exceptions

```dart
await telemetry.trace('payment', (span) async {
  try {
    await processPayment();
    telemetry.addEvent('payment_success');
  } catch (e) {
    telemetry.addExceptionEvent(e);
    rethrow;
  }
});
```

### Named Tracers

By default all spans go to the service's default tracer. Create named tracers for instrumenting libraries:

```dart
final tracer = telemetry.getTracer('email-service', version: '1.0');
await tracer.trace('send_email', {}, SpanType.client, (span) async {
  // ...
});
```

### Dart Developer Timeline

Traces are reported as `TimelineTask` events to the Dart developer timeline by default. Disable it if you only want OTEL export:

```yaml
telemetry:
  dartTimelineExporter:
    enable: false
```

View traces in [Dart DevTools](https://dart.dev/tools/dart-devtools) → Performance → Timeline.

### OpenTelemetry Export

Send traces to an OTEL collector:

```yaml
telemetry:
  openTelemetryExporter:
    enable: true
    host: otel-collector.internal
    port: 4317           # gRPC (default)
    sendInterval: 5      # seconds between batches (default)
    sendIntervalJitter: 2
```

---

## Full Configuration Reference

```yaml
telemetry:
  serviceName: MyApp           # Service name in traces / resource attrs
  logLevel: info               # trace | debug | info | warning | error | fatal
  logStdoutFormat: logfmt      # logfmt | json

  prometheusExporter:
    enabled: false
    address: null              # null = all interfaces
    port: 9090
    path: /metrics

  openTelemetryExporter:
    enable: false
    host: null
    port: 4317
    sendInterval: 5
    sendIntervalJitter: 2

  dartTimelineExporter:
    enable: true
```
