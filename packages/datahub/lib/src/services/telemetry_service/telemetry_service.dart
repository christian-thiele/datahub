import 'dart:async';
import 'dart:io';

import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:datahub/utils.dart';

export 'metrics/metric.dart';
export 'metrics/metric_collector.dart';
export 'metrics/metric_sample.dart';
export 'metrics/counter_metric.dart';
export 'metrics/gauge_metric.dart';
export 'metrics/histogram_metric.dart';
export 'metrics/prometheus_exporter.dart';
export 'metrics/sample_group.dart';
export 'metrics/metrics_exporter.dart';

export 'trace/event.dart';
export 'trace/discard_trace_exporter.dart';
export 'trace/open_telemetry_trace_exporter.dart';
export 'trace/span_id.dart';
export 'trace/span.dart';
export 'trace/trace_exporter.dart';
export 'trace/trace_id.dart';
export 'trace/trace_group.dart';
export 'trace/tracer.dart';

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
class TelemetryService extends BaseService {
  TelemetryService() : super('datahub.telemetry');

  late final enableEndpoint =
      config<bool?>('metrics.prometheusExporter.enable') ?? false;
  late final address = config<String?>('metrics.prometheusExporter.address');
  late final port = config<int?>('metrics.prometheusExporter.port') ?? 9090;
  late final path =
      config<String?>('metrics.prometheusExporter.path') ?? '/metrics';

  late final enableOtelExporter =
      config<bool?>('traces.openTelemetryExporter.enable') ?? false;
  late final otelCollectorHost =
      config<String?>('traces.openTelemetryExporter.host');
  late final otelCollectorPort =
      config<int?>('traces.openTelemetryExporter.port') ?? 4317;
  late final otelExporterSendInterval =
      config<int?>('traces.openTelemetryExporter.sendInterval') ?? 5;
  late final enableDartTimeline =
      config<bool?>('traces.dartTimelineExporter.enable') ?? true;

  late final MetricsExporter? _metricsExporter;
  late final TraceExporter _traceExporter;

  final _collectors = Set<MetricCollector>();
  final _metrics = <String, Metric>{};
  final _tracers = <String, Tracer>{};

  late final Tracer defaultTracer;
  final _scrapeMetric = GaugeMetric('datahub_instrumentation_scrape_duration');

  @override
  Future<void> initialize() async {
    if (enableEndpoint) {
      _metricsExporter = PrometheusExporter(
        address: address,
        port: port,
        path: path,
        onScrape: scrapeMetrics,
      );

      await _metricsExporter!.initialize();
    } else {
      _metricsExporter = null;
    }

    if (enableOtelExporter && otelCollectorHost != null) {
      _traceExporter = OpenTelemetryTraceExporter(
        host: otelCollectorHost!,
        port: otelCollectorPort,
        sendInterval: Duration(seconds: otelExporterSendInterval),
        resourceAttributes: {
          'service.name': resolve<ConfigService>().serviceName,
          'os.type': Platform.operatingSystem,
          'os.version': Platform.operatingSystemVersion,
          'os.hostname': Platform.localHostname,
          'dart.version': Platform.version,
        },
      );

      await _traceExporter.initialize();
    } else {
      _traceExporter = DiscardTraceExporter();
    }

    defaultTracer = getTracer(resolve<ConfigService>().serviceName);
  }

  /// Defines a metric of type [CounterMetric].
  ///
  /// If this was defined before, the same instance to the previously
  /// defined [CounterMetric] is returned. This allows for
  /// metric objects to be dependency injected and used across different
  /// places.
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

  /// Defines a metric of type [GaugeMetric].
  ///
  /// If this was defined before, the same instance to the previously
  /// defined [GaugeMetric] is returned. This allows for
  /// metric objects to be dependency injected and used across different
  /// places.
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

  /// Defines a metric of type [HistogramMetric] with linear bucket
  /// distribution.
  ///
  /// If this was defined before, the same instance to the previously
  /// defined [HistogramMetric] is returned. The parameters [start],
  /// [width] and [count] will be ignored in this case. This allows for
  /// metric objects to be dependency injected and used across different
  /// places.
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

  /// Defines a metric of type [HistogramMetric] with exponential bucket
  /// distribution.
  ///
  /// If this was defined before, the same instance to the previously
  /// defined [HistogramMetric] is returned. The parameters [start],
  /// [factor] and [count] will be ignored in this case. This allows for
  /// metric objects to be dependency injected and used across different
  /// places.
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

  /// Collects all current values of metrics into [SampleGroup]s.
  Future<List<SampleGroup>> scrapeMetrics() async {
    final samples = <SampleGroup>[];
    _scrapeMetric.measureDuration(() async {
      for (final _metric in _metrics.values) {
        samples.add(_metric.collect());
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
  void registerCollector(MetricCollector metricCollector) {
    _collectors.add(metricCollector);
  }

  /// Unregisters a custom collector.
  void unregisterCollector(MetricCollector metricCollector) {
    _collectors.remove(metricCollector);
  }

  FutureOr<R> trace<R>(
    String name,
    SpanType type,
    Map<String, dynamic> attributes,
    FutureOr<R> Function() delegate,
  ) async {
    return await defaultTracer.trace(name, attributes, delegate);
  }

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
  Future<void> shutdown() async {
    await _metricsExporter?.shutdown();
    await _traceExporter.shutdown();
  }
}
