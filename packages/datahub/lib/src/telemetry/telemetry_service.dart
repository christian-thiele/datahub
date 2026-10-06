import 'dart:async';
import 'dart:io';

import 'package:boost/boost.dart';
import 'package:datahub/config.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/utils.dart';
import 'package:grpc/grpc.dart'
    show ChannelCredentials, ChannelOptions, ClientChannel;

import 'logs/log_exporter.dart';
import 'logs/log_helper.dart';
import 'logs/log_listener.dart';
import 'logs/log_message.dart';
import 'logs/open_telemetry_log_exporter.dart';
import 'logs/severity_level.dart';
import 'logs/stdout_log_exporter.dart';
import 'metrics/counter_metric.dart';
import 'metrics/gauge_metric.dart';
import 'metrics/histogram_metric.dart';
import 'metrics/metric.dart';
import 'metrics/metric_collector.dart';
import 'metrics/metrics_exporter.dart';
import 'metrics/prometheus_exporter.dart';
import 'metrics/sample_group.dart';
import 'telemetry_internal.dart';
import 'telemetry_scope.dart';
import 'trace/discard_trace_exporter.dart';
import 'trace/open_telemetry_trace_exporter.dart';
import 'trace/span.dart';
import 'trace/trace_exporter.dart';
import 'trace/tracer.dart';

/// Logs, metrics and traces of the application.
///
/// See `doc/telemetry.md` of the datahub package for the conventions of
/// the framework, which also apply to application code.
///
/// ## Logs
///
/// Logs are written with the `log` helper (e.g. `log.info(...)`). Messages
/// are written to stdout and, if enabled, exported to an OpenTelemetry
/// collector. Messages logged within a span carry its trace and span id.
///
/// ## Metrics
///
/// Metrics are defined by the definition methods ([counter], [gauge],
/// [histogram], [linearHistogram], [exponentialHistogram]), which return
/// the same instance for the same name, so a metric can be used from
/// different places. Custom collectors can be added with
/// [registerCollector]. Metrics are exposed in the
/// [Prometheus text-based format](https://prometheus.io/docs/instrumenting/exposition_formats/#text-based-format),
/// see [scrapeMetrics].
///
/// ## Traces
///
/// Spans are created by [trace] (or a named [Tracer], see [getTracer]).
/// The active span is shared by all tracers and propagated through zones,
/// see [currentSpan]. Spans are exported to an OpenTelemetry collector if
/// enabled and reported to the Dart developer timeline.
///
/// ## Configuration (location: `telemetry`)
///
/// * `serviceName`: The `service.name` of the resource (default "DataHub")
/// * `serviceVersion`: The `service.version` of the resource (default null)
/// * `logLevel`: Minimum level of exported logs, `trace`, `debug`, `info`,
///   `warn`, `error` or `fatal` (default `debug`)
/// * `logStdoutFormat`: `logfmt`, `json`, `message` or `pretty` (default
///   `logfmt`)
/// * `prometheusExporter.enable`: Serve metrics for Prometheus (default
///   false)
/// * `prometheusExporter.address`: Address to listen on, null means any
///   (default null)
/// * `prometheusExporter.port`: Port to listen on (default 9090)
/// * `prometheusExporter.path`: Path of the metrics endpoint (default
///   `/metrics`)
/// * `openTelemetryExporter.enable`: Export to an OpenTelemetry collector
///   via OTLP/gRPC (default false)
/// * `openTelemetryExporter.host`: Host of the collector (default null)
/// * `openTelemetryExporter.port`: gRPC port of the collector (default 4317)
/// * `openTelemetryExporter.useTls`: Connect via TLS (default false)
/// * `openTelemetryExporter.exportInterval`: Interval of exports (default
///   5s)
/// * `openTelemetryExporter.exportIntervalJitter`: Maximum random delay
///   added to the interval (default 2s)
/// * `openTelemetryExporter.exportTraces`: Export spans (default true)
/// * `openTelemetryExporter.exportLogs`: Export logs (default true)
/// * `dartTimelineExporter.enable`: Report spans as `TimelineTask`s to the
///   Dart developer timeline (default true)
abstract interface class Telemetry {
  /// Writes a [LogMessage] to the log exporters and [LogListener]s.
  void publishLog(LogMessage message);

  /// Defines a metric of type [CounterMetric].
  ///
  /// If the named metric was defined before, the previously defined
  /// [CounterMetric] is returned and [labels], [labelNames] and [help] are
  /// ignored. This allows for metric objects to be dependency injected and
  /// used across different places.
  ///
  /// Labels are declared either with their values ([labels]) or by name
  /// only ([labelNames]), see [CounterMetric].
  CounterMetric counter(
    String name, {
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
    String? help,
  });

  /// Defines a metric of type [GaugeMetric].
  ///
  /// See [counter] for metrics defined before and labels.
  GaugeMetric gauge(
    String name, {
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
    String? help,
  });

  /// Defines a metric of type [HistogramMetric] with the given upper bucket
  /// boundaries, e.g. [HistogramMetric.defaultDurationBuckets].
  ///
  /// See [counter] for metrics defined before (the buckets are ignored
  /// then) and labels.
  HistogramMetric histogram(
    String name, {
    required List<num> buckets,
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
    String? help,
  });

  /// Defines a metric of type [HistogramMetric] with linear bucket
  /// distribution, see [HistogramMetric.linear].
  ///
  /// See [counter] for metrics defined before (the buckets are ignored
  /// then) and labels.
  HistogramMetric linearHistogram(
    String name, {
    required num start,
    required num width,
    required int count,
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
    String? help,
  });

  /// Defines a metric of type [HistogramMetric] with exponential bucket
  /// distribution, see [HistogramMetric.exponential].
  ///
  /// See [counter] for metrics defined before (the buckets are ignored
  /// then) and labels.
  HistogramMetric exponentialHistogram(
    String name, {
    required num start,
    required num factor,
    required int count,
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
    String? help,
  });

  /// Collects all current values of metrics into [SampleGroup]s.
  Future<List<SampleGroup>> scrapeMetrics();

  /// Registers a custom collector.
  ///
  /// Custom collectors can fetch metrics from other services,
  /// query values from databases or generate values in any other way.
  ///
  /// For simple metrics like counters or gauges prefer using one of the
  /// definition methods:
  ///  - [counter]
  ///  - [gauge]
  ///  - [histogram]
  ///  - [linearHistogram]
  ///  - [exponentialHistogram]
  void registerCollector(MetricCollector metricCollector);

  /// Unregisters a custom collector.
  void unregisterCollector(MetricCollector metricCollector);

  /// Runs [delegate] in a new span of the default tracer, see
  /// [Tracer.trace].
  Future<R> trace<R>(
    String name,
    FutureOr<R> Function(LocalSpan span) delegate, {
    SpanType type = SpanType.internal,
    Map<String, Object?>? attributes,
    Span? parent,
  });

  /// The active span of the current zone, see [Tracer.currentSpan].
  Span? get currentSpan;

  /// Adds an event to the [currentSpan], if it is a [LocalSpan].
  void addEvent(String name, {Map<String, Object?>? attributes});

  /// Records [error] on the [currentSpan], if it is a [LocalSpan], see
  /// [LocalSpan.recordException].
  void recordException(Object error, {StackTrace? stack, bool setError = true});

  /// The spans of all tracers once they ended, e.g. for tests.
  ///
  /// This is a synchronous broadcast stream, so listeners are called when
  /// [LocalSpan.end] is called.
  Stream<LocalSpan> get endedSpans;

  /// Returns a named tracer.
  ///
  /// In most cases the convenience methods for using the default tracer
  /// are sufficient:
  ///   - [trace]
  ///   - [addEvent]
  ///   - [recordException]
  Tracer getTracer(String name, {String? version});

  /// Returns the default tracer, which is named after the service.
  Tracer getDefaultTracer();
}

class TelemetryService implements Service {
  final Config<String> serviceName;
  final Config<String?> serviceVersion;

  final Config<SeverityLevel> logLevel;
  final Config<LogBodyFormat> logStdoutFormat;

  final Config<bool> enablePrometheusExporter;
  final Config<String?> prometheusExporterAddress;
  final Config<int> prometheusExporterPort;
  final Config<String> prometheusExporterPath;

  final Config<bool> enableOtelExporter;
  final Config<String?> otelCollectorHost;
  final Config<int> otelCollectorPort;
  final Config<bool> otelUseTls;
  final Config<Duration> otelExportInterval;
  final Config<Duration> otelExportIntervalJitter;
  final Config<bool> otelExportTraces;
  final Config<bool> otelExportLogs;

  final Config<bool> enableDartTimeline;

  const TelemetryService({
    this.serviceName = const Config<String>(
      'telemetry.serviceName',
      defaultValue: 'DataHub',
    ),
    this.serviceVersion = const Config<String?>('telemetry.serviceVersion'),
    this.logLevel = const Config<SeverityLevel>(
      'telemetry.logLevel',
      defaultValue: SeverityLevel.debug,
      values: SeverityLevel.values,
    ),
    this.logStdoutFormat = const Config(
      'telemetry.logStdoutFormat',
      defaultValue: LogBodyFormat.logfmt,
      values: LogBodyFormat.values,
    ),
    this.enablePrometheusExporter = const Config<bool>(
      'telemetry.prometheusExporter.enable',
      defaultValue: false,
    ),
    this.prometheusExporterAddress = const Config<String?>(
      'telemetry.prometheusExporter.address',
    ),
    this.prometheusExporterPort = const Config<int>(
      'telemetry.prometheusExporter.port',
      defaultValue: 9090,
    ),
    this.prometheusExporterPath = const Config<String>(
      'telemetry.prometheusExporter.path',
      defaultValue: '/metrics',
    ),
    this.enableOtelExporter = const Config<bool>(
      'telemetry.openTelemetryExporter.enable',
      defaultValue: false,
    ),
    this.otelCollectorHost = const Config<String?>(
      'telemetry.openTelemetryExporter.host',
    ),
    this.otelCollectorPort = const Config<int>(
      'telemetry.openTelemetryExporter.port',
      defaultValue: 4317,
    ),
    this.otelUseTls = const Config<bool>(
      'telemetry.openTelemetryExporter.useTls',
      defaultValue: false,
    ),
    this.otelExportInterval = const Config<Duration>(
      'telemetry.openTelemetryExporter.exportInterval',
      defaultValue: Duration(seconds: 5),
    ),
    this.otelExportIntervalJitter = const Config<Duration>(
      'telemetry.openTelemetryExporter.exportIntervalJitter',
      defaultValue: Duration(seconds: 2),
    ),
    this.otelExportTraces = const Config<bool>(
      'telemetry.openTelemetryExporter.exportTraces',
      defaultValue: true,
    ),
    this.otelExportLogs = const Config<bool>(
      'telemetry.openTelemetryExporter.exportLogs',
      defaultValue: true,
    ),
    this.enableDartTimeline = const Config<bool>(
      'telemetry.dartTimelineExporter.enable',
      defaultValue: true,
    ),
  });

  @override
  ServiceInstance<TelemetryService> createInstance() =>
      _TelemetryServiceInstance();
}

class _TelemetryServiceInstance extends ServiceInstance<TelemetryService>
    implements Telemetry {
  late final SeverityLevel _logLevel;
  late final LogExporter _stdoutExporter;
  late final OpenTelemetryLogExporter? _otelLogExporter;
  late final MetricsExporter? _metricsExporter;
  late final TraceExporter _traceExporter;
  late final ClientChannel? _otelChannel;
  late final bool _enableDartTimeline;

  final _collectors = <MetricCollector>{};
  final _metrics = <String, Metric>{};
  final _tracers = <String, Tracer>{};
  final _endedSpans = StreamController<LocalSpan>.broadcast(sync: true);

  late final Tracer defaultTracer;
  final _scrapeMetric = GaugeMetric(
    'datahub_telemetry_scrape_duration_seconds',
    help: 'Time it took to collect the metrics of the last scrape.',
  );

  @override
  Future<void> initialize() async {
    await super.initialize();
    final resourceAttributes = _resourceAttributes();

    _logLevel = read(service.logLevel);
    _stdoutExporter = StdoutLogExporter(read(service.logStdoutFormat));
    _enableDartTimeline = read(service.enableDartTimeline);

    if (read(service.enablePrometheusExporter)) {
      _metricsExporter = PrometheusExporter(
        address: read(service.prometheusExporterAddress),
        port: read(service.prometheusExporterPort),
        path: read(service.prometheusExporterPath),
        onScrape: scrapeMetrics,
      );

      await _metricsExporter!.initialize();
    } else {
      _metricsExporter = null;
    }

    final otelHost = read(service.otelCollectorHost);
    if (read(service.enableOtelExporter) && !nullOrWhitespace(otelHost)) {
      final channel = _otelChannel = ClientChannel(
        otelHost!,
        port: read(service.otelCollectorPort),
        options: ChannelOptions(
          credentials: read(service.otelUseTls)
              ? const ChannelCredentials.secure()
              : const ChannelCredentials.insecure(),
        ),
      );
      final interval = read(service.otelExportInterval);
      final jitter = read(service.otelExportIntervalJitter);

      _traceExporter = read(service.otelExportTraces)
          ? OpenTelemetryTraceExporter(
              channel: channel,
              exportInterval: interval,
              exportIntervalJitter: jitter,
              resourceAttributes: resourceAttributes,
            )
          : DiscardTraceExporter();
      _otelLogExporter = read(service.otelExportLogs)
          ? OpenTelemetryLogExporter(
              channel: channel,
              exportInterval: interval,
              exportIntervalJitter: jitter,
              scope: const SimpleTelemetryScope('datahub'),
              resourceAttributes: resourceAttributes,
            )
          : null;
    } else {
      _otelChannel = null;
      _traceExporter = DiscardTraceExporter();
      _otelLogExporter = null;
      if (read(service.enableOtelExporter)) {
        log.warn(
          'OpenTelemetry exporter is enabled, but no collector host is '
          'configured (telemetry.openTelemetryExporter.host).',
        );
      }
    }

    await _traceExporter.initialize();
    await _otelLogExporter?.initialize();

    defaultTracer = getTracer(read(service.serviceName));
  }

  /// Resource attributes according to the semantic conventions.
  Map<String, Object?> _resourceAttributes() => {
    'service.name': read(service.serviceName),
    'service.version': read(service.serviceVersion),
    'service.instance.id': uuid(),
    'deployment.environment.name': context.environment.name,
    'host.name': Platform.localHostname,
    'os.type': switch (Platform.operatingSystem) {
      'macos' || 'ios' => 'darwin',
      'android' => 'linux',
      final os => os,
    },
    'os.description': Platform.operatingSystemVersion,
    'process.pid': pid,
    'process.runtime.name': 'dart',
    'process.runtime.version': Platform.version.split(' ').first,
    'telemetry.sdk.name': 'datahub',
    'telemetry.sdk.language': 'dart',
  };

  @override
  void publishLog(LogMessage message) {
    if (message.level.severityNumber >= _logLevel.severityNumber) {
      _stdoutExporter.add(message);
      // logs of the exporters themselves are not exported
      if (!TelemetryInternal.isActive) {
        _otelLogExporter?.add(message);
      }
    }

    try {
      LogListener.current?.publishLog(message);
    } catch (e, stack) {
      _stdoutExporter.add(
        LogMessage(
          timestamp: DateTime.timestamp(),
          line: 'Error in LogListener.',
          level: SeverityLevel.error,
          error: e,
          stack: stack,
          span: currentSpan,
        ),
      );
    }
  }

  @override
  CounterMetric counter(
    String name, {
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
    String? help,
  }) => _define(
    name,
    () =>
        CounterMetric(name, labels: labels, labelNames: labelNames, help: help),
  );

  @override
  GaugeMetric gauge(
    String name, {
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
    String? help,
  }) => _define(
    name,
    () => GaugeMetric(name, labels: labels, labelNames: labelNames, help: help),
  );

  @override
  HistogramMetric histogram(
    String name, {
    required List<num> buckets,
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
    String? help,
  }) => _define(
    name,
    () => HistogramMetric(
      name,
      buckets: buckets,
      labels: labels,
      labelNames: labelNames,
      help: help,
    ),
  );

  @override
  HistogramMetric linearHistogram(
    String name, {
    required num start,
    required num width,
    required int count,
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
    String? help,
  }) => _define(
    name,
    () => HistogramMetric.linear(
      name,
      start: start,
      width: width,
      count: count,
      labels: labels,
      labelNames: labelNames,
      help: help,
    ),
  );

  @override
  HistogramMetric exponentialHistogram(
    String name, {
    required num start,
    required num factor,
    required int count,
    Map<String, List<String>>? labels,
    Set<String>? labelNames,
    String? help,
  }) => _define(
    name,
    () => HistogramMetric.exponential(
      name,
      start: start,
      factor: factor,
      count: count,
      labels: labels,
      labelNames: labelNames,
      help: help,
    ),
  );

  /// Returns the metric [name] if it was defined before, otherwise defines
  /// it with [create].
  T _define<T extends Metric>(String name, T Function() create) {
    return switch (_metrics[name]) {
      final T existing => existing,
      null => _metrics[name] = create(),
      final existing => throw ApiError(
        'Metric $name is already defined with a different type: $existing',
      ),
    };
  }

  @override
  Future<List<SampleGroup>> scrapeMetrics() async {
    final samples = await _scrapeMetric.measureDurationAsync(() async {
      return [
        for (final metric in _metrics.values) metric.collect(),
        for (final collector in _collectors.toList())
          switch (collector) {
            SyncMetricCollector collector => collector.collect(),
            AsyncMetricCollector collector => await collector.collect(),
          },
      ];
    });
    return [_scrapeMetric.collect(), ...samples];
  }

  @override
  void registerCollector(MetricCollector metricCollector) {
    _collectors.add(metricCollector);
  }

  @override
  void unregisterCollector(MetricCollector metricCollector) {
    _collectors.remove(metricCollector);
  }

  @override
  Future<R> trace<R>(
    String name,
    FutureOr<R> Function(LocalSpan span) delegate, {
    SpanType type = SpanType.internal,
    Map<String, Object?>? attributes,
    Span? parent,
  }) => defaultTracer.trace(
    name,
    delegate,
    type: type,
    attributes: attributes,
    parent: parent,
  );

  @override
  Span? get currentSpan => Tracer.currentSpan;

  @override
  void addEvent(String name, {Map<String, Object?>? attributes}) {
    if (currentSpan case LocalSpan span) {
      span.addEvent(name, attributes: attributes);
    }
  }

  @override
  void recordException(
    Object error, {
    StackTrace? stack,
    bool setError = true,
  }) {
    if (currentSpan case LocalSpan span) {
      span.recordException(error, stack: stack, setError: setError);
    }
  }

  @override
  Stream<LocalSpan> get endedSpans => _endedSpans.stream;

  @override
  Tracer getTracer(String name, {String? version}) {
    final key = Tracer.buildKey(name, version);
    return _tracers[key] ??= Tracer(
      name: name,
      version: version,
      enableDartTimeline: _enableDartTimeline,
      exporter: _traceExporter,
      onEnd: (span) {
        if (!_endedSpans.isClosed) {
          _endedSpans.add(span);
        }
      },
      attributes: {},
    );
  }

  @override
  Tracer getDefaultTracer() => defaultTracer;

  @override
  Future<void> dispose() async {
    await _metricsExporter?.shutdown();
    await _traceExporter.shutdown();
    await _otelLogExporter?.shutdown();
    await _otelChannel?.shutdown();
    await _endedSpans.close();
    await super.dispose();
  }
}
