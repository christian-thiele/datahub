# Telemetry guidelines

Conventions for logs, metrics and traces in DataHub. They follow the
[OpenTelemetry semantic conventions](https://opentelemetry.io/docs/specs/semconv/) and the
[Prometheus naming practices](https://prometheus.io/docs/practices/naming/), and apply to framework code as well as
to applications built with it. `RedisTelemetry` (`datahub_redis`) and `PostgresqlTelemetry` (`datahub_postgres`) are
reference implementations.

## General

- **Telemetry never breaks the application.** Recording a metric, adding a span attribute or logging never throws
  into application code. Exporters handle their own failures and report them only to stdout.
- **Getting telemetry:** services use `Find<Telemetry>`. Code outside of services (HTTP server and client, sessions,
  helpers) uses `Context.maybeOfZone()?.find(Find<Telemetry?>())` and keeps working without telemetry.
- **Component config:** every instrumented component has `enableMetrics`, `enableTracing` (both default `true`) and
  `metricPrefix`. Bundle the instrumentation of an integration in one `<Integration>Telemetry` class with a no-op
  `disabled` instance, so call sites don't check the flags.
- **Names:** use the semantic convention names where they exist. Custom attributes, span attributes and log labels go
  under `datahub.<component>.<attribute>` (e.g. `datahub.workflow.step`, `datahub.task.invocation.id`), lowercase,
  dot-separated, `snake_case` within a segment. Spans and logs of the same operation use the same keys.
- **No secrets, no unbounded payloads.** Credentials are never logged or attached (see `Redaction`). Values like
  query texts with inlined values or request bodies are only recorded when the user opts in (e.g. `logStatements`,
  `logRequests`).

## Traces

- **Span kinds:**
  - `server`: handling an incoming request.
  - `client`: an outgoing call (HTTP, database, cache).
  - `consumer` / `producer`: processing / creating a stored event or message (e.g. a workflow step).
  - `internal`: everything else.
- **One server span per incoming request**, created by the transport (`HttpServer`). Higher layers such as
  `ApiService` enrich the current span (`Tracer.currentSpan`: `http.route`, `updateName`, exceptions) instead of
  nesting another span.
- **Span names** are low cardinality: `{operation} {target}` as in the semantic conventions, e.g. `GET /orders/{id}`,
  `SELECT`, `GET` (Redis). Never put ids, paths or values in names.
- **Attributes** are typed (`int`, `double`, `bool`, `String` or lists of those). Use `setAttribute`, which replaces
  existing values.
- **Status:** leave it unset. Call `setError` only when the operation of the span failed. Server spans don't fail
  for client errors (4xx), client spans do. On failure set `error.type` (an error code or the exception type).
- **Exceptions:** `recordException(error, stack: stack)` adds an `exception` event (`exception.type`,
  `exception.message`, `exception.stacktrace`) and fails the span. Pass `setError: false` for expected errors caused
  by the caller. `trace()` records exceptions thrown by its delegate.
- **Lifecycle:** prefer `trace()`, which makes the span active for the code it runs and ends it. Spans are exported
  when they start, so a span is visible even if the service crashes, and again when they end if they were exported
  while running. Always end spans created by `startSpan`.
- **Propagation:** across processes with the W3C `traceparent` header (`TraceContext`, done by `HttpServer` and
  `HttpClient`). Stored work (e.g. workflow events) stores the trace and span id and continues with
  `trace(..., parent: Span.remote(...))`. Spans of unsampled traces are created (for log correlation) but not
  exported.

## Metrics

- **Names:** `<prefix>_<noun>_<unit>` in `snake_case`, with base units (`_seconds`, `_bytes`). Counters end in
  `_total`, gauges never do (e.g. `redis_commands_total`, `api_request_duration_seconds`, `redis_pool_size_total`).
- **Help text** on every metric.
- **Labels** are bounded. Declare them up front, with all values (`labels`), or by name for values that are bounded
  but not known in advance, like routes or status codes (`labelNames`). Never use ids, paths, keys or user input as
  label values. Label names are the semantic convention attribute names with `.` replaced by `_` (e.g.
  `http_request_method`, `error_type`), or short `snake_case` names. Values for undeclared labels are dropped with one
  warning per metric.
- **Durations** are histograms in seconds, using `HistogramMetric.defaultDurationBuckets` unless there is a reason
  for other buckets.
- Define metrics through `Telemetry` (`counter`, `gauge`, `histogram`, ...), which returns the existing instance for
  the same name.

## Logs

- **Levels:**
  - `trace`: per-request or per-query detail (statements, request records).
  - `debug`: internal state changes.
  - `info`: lifecycle events (started, listening, shut down).
  - `warn`: recoverable problems or degraded operation.
  - `error`: an operation failed and needs attention.
  - `fatal`: the process cannot continue.
- **Messages** are short, constant sentences. Variable data goes into labels, using the same keys as span
  attributes. Pass `error:` and `stack:` instead of interpolating them into the message.
- **Correlation** is automatic: logs within a span carry its trace and span id (`trace_id`, `span_id` on stdout).
- **Severity** is encoded with `SeverityLevel`, a `DataEnum` (`trace`, `debug`, `info`, `warn`, `error`, `fatal`),
  in config values and stored messages. Log output uses the upper case short names (`WARN`).

## Configuration

See `TelemetryService` for all options (location `telemetry`). Exporting to an OpenTelemetry collector:

```yaml
telemetry:
  serviceName: orders
  serviceVersion: 1.4.2
  openTelemetryExporter:
    enable: true
    host: otel-collector
    port: 4317
  prometheusExporter:
    enable: true
```

## Testing

- **Spans:** listen to `Telemetry.endedSpans`, see `test/api/server_span_test.dart`. To check exports, override
  `OpenTelemetryTraceExporter.send`, see `test/telemetry/trace_test.dart`.
- **Logs:** run the code in a `LogListener`, see `test/telemetry/logs_test.dart`.
- **Metrics:** `Telemetry.scrapeMetrics()`, see `test/telemetry/metrics_test.dart`.
