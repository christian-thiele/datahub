import 'dart:async';
import 'dart:io';

import 'package:datahub/config.dart';
import 'package:datahub/utils.dart';

import 'logs/log_exporter.dart';
import 'logs/log_listener.dart';
import 'logs/log_message.dart';
import 'logs/severity_level.dart';
import 'logs/stdout_log_exporter.dart';

import 'metrics/metric.dart';
import 'metrics/metric_collector.dart';
import 'metrics/counter_metric.dart';
import 'metrics/gauge_metric.dart';
import 'metrics/histogram_metric.dart';
import 'metrics/prometheus_exporter.dart';
import 'metrics/sample_group.dart';
import 'metrics/metrics_exporter.dart';

import 'trace/discard_trace_exporter.dart';
import 'trace/open_telemetry_trace_exporter.dart';
import 'trace/span.dart';
import 'trace/trace_exporter.dart';
import 'trace/tracer.dart';

import 'package:datahub/scaffold.dart';

/// Internal service for collecting and exposing application metrics.
///
/// ## Metrics
///
/// For exposing metrics, creating [Metric] instances is required, which provide
/// a handle for the given metric. Best practice for creating metric instances
/// is by using the metric definition methods on [TelemetryService]:
/// * [counter]
/// * [gauge]
/// * [linearHistogram]
/// * [exponentialHistogram]
///
/// This way, the same metric can be injected from different places inside the
/// application. If instantiated separately through their constructor, they
/// have to be registered at the [TelemetryService] by invoking the
/// [register] method.
///
/// In terms of Prometheus conventions, this service provides the
/// "CollectorRegistry" and the "Bridge" to the Prometheus text based format.
///
/// Metrics can be scraped (see [scrapeMetrics]) into samples, which provide a
/// snapshot of all of the current values. Usually this is done via the
/// metrics endpoint, which provides the [prometheus text-bases format](https://prometheus.io/docs/instrumenting/exposition_formats/#text-based-format)
/// for exposing metrics.
///
/// Configuration values: (location: "datahub.telemetry.metrics")
///
/// * `prometheusExporter.enable`: Enable prometheus text-based format endpoint (default false)
/// * `prometheusExporter.address`: The address the HTTP-Server listens for, null means any (default null)
/// * `prometheusExporter.port`: The port the HTTP-Server listens on (default 9090)
/// * `prometheusExporter.path`: The path of the metrics endpoint (default "/metrics")
/// * `dartTimelineExporter.enable`: Enable reporting trace spans as TimelineTasks to the dart developer timeline (default true)
///
/// ## Traces
///
/// //TODO docs
///
/// Configuration values: (location: "datahub.telemetry.traces")
///
/// * `openTelemetryExporter.enable`: Enable reporting trace spans to a OpenTelemetry collector (default false)
/// * `openTelemetryExporter.host`: OpenTelemetry collector host (default null)
/// * `openTelemetryExporter.port`: OpenTelemetry collector grpc port (default 4317)
/// * `openTelemetryExporter.sendInterval`: The interval in which traces are sent to the collector in seconds (default 5)
///
/// * `dartTimelineExporter.enable`: Enable reporting trace spans as TimelineTasks to the dart developer timeline (default true)
///
abstract interface class Telemetry {
  /// Writes a [LogMessage] to the configured log receiver.
  void publishLog(LogMessage message);

  /// Defines a metric of type [CounterMetric].
  ///
  /// If the named metric  was defined before, the same instance to the
  /// previously efined [CounterMetric] is returned. This allows for
  /// metric objects to be dependency injected and used across different
  /// places.
  CounterMetric counter(
    String name, {
    Map<String, List<String>>? labels,
    String? help,
  });

  /// Defines a metric of type [GaugeMetric].
  ///
  /// If the named metric was defined before, the same instance to the
  /// previously defined [GaugeMetric] is returned. This allows for
  /// metric objects to be dependency injected and used across different
  /// places.
  GaugeMetric gauge(
    String name, {
    Map<String, List<String>>? labels,
    String? help,
  });

  /// Defines a metric of type [HistogramMetric] with linear bucket
  /// distribution.
  ///
  /// If the named metric was defined before, the same instance to the
  /// previously defined [HistogramMetric] is returned. The parameters [start],
  /// [width] and [count] will be ignored in this case. This allows for
  /// metric objects to be dependency injected and used across different
  /// places.
  HistogramMetric linearHistogram(
    String name, {
    required num start,
    required num width,
    required int count,
    String? help,
  });

  /// Defines a metric of type [HistogramMetric] with exponential bucket
  /// distribution.
  ///
  /// If the named metric was defined before, the same instance to the
  /// previously defined [HistogramMetric] is returned. The parameters [start],
  /// [factor] and [count] will be ignored in this case. This allows for
  /// metric objects to be dependency injected and used across different
  /// places.
  HistogramMetric exponentialHistogram(
    String name, {
    required num start,
    required num factor,
    required int count,
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
  ///  - [linearHistogram]
  ///  - [exponentialHistogram]
  void registerCollector(MetricCollector metricCollector);

  /// Unregisters a custom collector.
  void unregisterCollector(MetricCollector metricCollector);

  /// Convenience method for using the default tracer to trace a span.
  FutureOr<R> trace<R>(
    String name,
    FutureOr<R> Function(LocalSpan span) delegate, {
    SpanType type = SpanType.internal,
    Map<String, dynamic> attributes,
  });

  /// Convenience methods for using the default tracer to trace an event.
  void addEvent(String name, {Map<String, String>? arguments});

  /// Convenience methods for using the default tracer to trace an exception
  /// event and marking the current span as error.
  void addExceptionEvent(dynamic error);

  /// Returns a named tracer.
  ///
  /// In most cases the convenience methods for using the default tracer
  /// are sufficient:
  ///   - [trace]
  ///   - [addEvent]
  ///   - [addExceptionEvent]
  Tracer getTracer(String name, {String? version});

  /// Returns the default tracer.
  ///
  /// In most cases the convenience methods for using the default tracer
  /// are sufficient:
  ///   - [trace]
  ///   - [addEvent]
  ///   - [addExceptionEvent]
  Tracer getDefaultTracer();
}

class TelemetryService implements Service {
  // TODO refactor / sort config vars
  final Config<String> serviceName;

  final Config<bool> enableEndpoint;
  final Config<String?> address;
  final Config<int> port;
  final Config<String> path;

  final Config<bool> enableOtelExporter;
  final Config<String?> otelCollectorHost;
  final Config<int> otelCollectorPort;
  final Config<int> otelExporterSendInterval;
  final Config<int> otelExporterSendIntervalJitter;

  final Config<bool> enableDartTimeline;

  final Config<LogBodyFormat> logStdoutFormat;
  final Config<SeverityLevel> logLevel;

  const TelemetryService({
    this.serviceName = const Config<String>(
      'telemetry.serviceName',
      defaultValue: 'DataHub',
    ),
    this.enableEndpoint = const Config<bool>(
      'telemetry.prometheusExporter.enabled',
      defaultValue: false,
    ),
    this.address = const Config<String?>(
      'telemetry.prometheusExporter.address',
    ),
    this.port = const Config<int>(
      'telemetry.prometheusExporter.port',
      defaultValue: 9090,
    ),
    this.path = const Config<String>(
      'telemetry.prometheusExporter.path',
      defaultValue: 'metrics',
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
    this.otelExporterSendInterval = const Config<int>(
      'telemetry.openTelemetryExporter.sendInterval',
      defaultValue: 5,
    ),
    this.otelExporterSendIntervalJitter = const Config<int>(
      'telemetry.openTelemetryExporter.sendIntervalJitter',
      defaultValue: 2,
    ),
    this.enableDartTimeline = const Config<bool>(
      'telemetry.dartTimelineExporter.enable',
      defaultValue: true,
    ),
    this.logStdoutFormat = const Config(
      'telemetry.logStdoutFormat',
      defaultValue: LogBodyFormat.logfmt,
      values: LogBodyFormat.values,
    ),
    this.logLevel = const Config<SeverityLevel>(
      'telemetry.logLevel',
      defaultValue: SeverityLevel.debug,
      values: SeverityLevel.values,
    ),
  });

  @override
  ServiceInstance<TelemetryService> createInstance() =>
      _TelemetryServiceInstance();
}

class _TelemetryServiceInstance extends ServiceInstance<TelemetryService>
    implements Telemetry {
  late final LogExporter _logExporter;
  late final MetricsExporter? _metricsExporter;
  late final TraceExporter _traceExporter;

  final _collectors = <MetricCollector>{};
  final _metrics = <String, Metric>{};
  final _tracers = <String, Tracer>{};

  late final Tracer defaultTracer;
  final _scrapeMetric = GaugeMetric('datahub_instrumentation_scrape_duration');

  late final SeverityLevel logLevel;

  @override
  Future<void> initialize() async {
    await super.initialize();
    final resourceAttributes = {
      'service.name': read(service.serviceName),
      'os.type': Platform.operatingSystem,
      'os.version': Platform.operatingSystemVersion,
      'os.hostname': Platform.localHostname,
      'dart.version': Platform.version,
    };

    logLevel = read(service.logLevel);
    _logExporter = StdoutLogExporter(read(service.logStdoutFormat));

    if (read(service.enableEndpoint)) {
      _metricsExporter = PrometheusExporter(
        address: read(service.address),
        port: read(service.port),
        path: read(service.path),
        onScrape: scrapeMetrics,
      );

      await _metricsExporter!.initialize();
    } else {
      _metricsExporter = null;
    }

    if (read(service.enableOtelExporter) &&
        read(service.otelCollectorHost) != null) {
      _traceExporter = OpenTelemetryTraceExporter(
        host: read(service.otelCollectorHost)!,
        port: read(service.otelCollectorPort),
        sendInterval: Duration(seconds: read(service.otelExporterSendInterval)),
        sendIntervalJitter: Duration(
          seconds: read(service.otelExporterSendIntervalJitter),
        ),
        resourceAttributes: resourceAttributes,
      );

      await _traceExporter.initialize();
    } else {
      _traceExporter = DiscardTraceExporter();
    }

    defaultTracer = getTracer(read(service.serviceName));
  }

  @override
  void publishLog(LogMessage message) {
    if (message.level.severityNumber >= logLevel.severityNumber) {
      _logExporter.add(message);
    }

    try {
      LogListener.current?.onPublish(message);
    } catch (e, stack) {
      _logExporter.add(
        LogMessage(
          timestamp: DateTime.timestamp(),
          line: 'Error in LogListener.',
          level: SeverityLevel.error,
          error: e,
          stack: stack,
          span: defaultTracer.findParentSpan(),
        ),
      );
    }
  }

  @override
  CounterMetric counter(
    String name, {
    Map<String, List<String>>? labels,
    String? help,
  }) {
    return switch (_metrics[name]) {
      final CounterMetric existing => existing,
      null => _metrics[name] = CounterMetric(name, labels: labels, help: help),
      final existing => throw ApiError(
        'Metric $name is already defined with different type: $existing',
      ),
    };
  }

  @override
  GaugeMetric gauge(
    String name, {
    Map<String, List<String>>? labels,
    String? help,
  }) {
    return switch (_metrics[name]) {
      final GaugeMetric existing => existing,
      null => _metrics[name] = GaugeMetric(name, labels: labels, help: help),
      final existing => throw ApiError(
        'Metric $name is already defined with different type: $existing',
      ),
    };
  }

  @override
  HistogramMetric linearHistogram(
    String name, {
    required num start,
    required num width,
    required int count,
    String? help,
  }) {
    return switch (_metrics[name]) {
      final HistogramMetric existing => existing,
      null => _metrics[name] = HistogramMetric.linear(
        name,
        start: start,
        width: width,
        count: count,
        help: help,
      ),
      final existing => throw ApiError(
        'Metric already defined with different type: $existing',
      ),
    };
  }

  @override
  HistogramMetric exponentialHistogram(
    String name, {
    required num start,
    required num factor,
    required int count,
    String? help,
  }) {
    return switch (_metrics[name]) {
      final HistogramMetric existing => existing,
      null => _metrics[name] = HistogramMetric.exponential(
        name,
        start: start,
        factor: factor,
        count: count,
        help: help,
      ),
      final existing => throw ApiError(
        'Metric already defined with different type: $existing',
      ),
    };
  }

  @override
  Future<List<SampleGroup>> scrapeMetrics() async {
    final samples = <SampleGroup>[];
    _scrapeMetric.measureDuration(() async {
      for (final metric in _metrics.values) {
        samples.add(metric.collect());
      }
      for (final collector in _collectors) {
        switch (collector) {
          case SyncMetricCollector collector:
            samples.add(collector.collect());
          case AsyncMetricCollector collector:
            samples.add(await collector.collect());
        }
      }
    });
    samples.insert(0, _scrapeMetric.collect());
    return samples;
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
  FutureOr<R> trace<R>(
    String name,
    FutureOr<R> Function(LocalSpan span) delegate, {
    SpanType type = SpanType.internal,
    Map<String, dynamic> attributes = const <String, dynamic>{},
  }) async {
    return await defaultTracer.trace(name, attributes, type, delegate);
  }

  @override
  void addEvent(String name, {Map<String, dynamic>? arguments}) {
    if (defaultTracer.findParentSpan() case LocalSpan span) {
      span.addEvent(name, arguments: arguments);
    }
  }

  @override
  void addExceptionEvent(dynamic error) {
    if (defaultTracer.findParentSpan() case LocalSpan span) {
      span.addExceptionEvent(error);
    }
  }

  @override
  Tracer getTracer(String name, {String? version}) {
    final key = Tracer.buildKey(name, version);
    return _tracers[key] ??= Tracer(
      name: name,
      version: version,
      enableDartTimeline: true,
      sink: _traceExporter,
      attributes: {},
    );
  }

  @override
  Tracer getDefaultTracer() => defaultTracer;

  @override
  Future<void> dispose() async {
    await _metricsExporter?.shutdown();
    await _traceExporter.shutdown();
    await super.dispose();
  }
}
