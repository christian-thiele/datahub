import 'dart:async';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:datahub/utils.dart';

import 'metric.dart';
import 'metric_collector.dart';
import 'metric_sample.dart';
import 'prometheus_bridge.dart';
import 'trace/tracer.dart';

export 'counter_metric.dart';
export 'gauge_metric.dart';
export 'histogram_metric.dart';

/// Internal service for collecting and exposing application metrics.
///
/// In terms of Prometheus conventions, this service provides the
/// "CollectorRegistry" and the "Bridge" to the Prometheus text based format.
///
/// Configuration values: (below "datahub.metrics")
/// * `enableEndpoint`: Enable prometheus text-based format endpoint (default false)
/// * `address`: The address the HTTP-Server listens for, null means any (default null)
/// * `port`: The port the HTTP-Server listens on (default 9090)
/// * `path`: The path of the metrics endpoint (default "/metrics")
/// * `enableDartTimeline`: Enable reporting trace spans as TimelineTasks to the dart developer timeline (default true)
///
/// For exposing metrics, creating [Metric] instances is required, which provide
/// a handle for the given metric. Best practice for creating metric instances
/// is by using the metric definition methods on [InstrumentationService]:
/// * [counter]
/// * [gauge]
/// * [linearHistogram]
/// * [exponentialHistogram]
///
/// This way, the same metric can be injected from different places inside the
/// application. If instantiated separately through their constructor, they
/// have to be registered at the [InstrumentationService] by invoking the
/// [register] method.
///
/// Metrics can be scraped (see [scrape]) into samples, which provide a
/// snapshot of all of the current values. Usually this is done via the
/// metrics endpoint, which provides the [prometheus text-bases format](https://prometheus.io/docs/instrumenting/exposition_formats/#text-based-format)
/// for exposing metrics.
class InstrumentationService extends BaseService {
  InstrumentationService() : super('datahub.metrics');

  final MetricBridge _bridge = PrometheusBridge();
  late final enableEndpoint = config<bool?>('enableEndpoint') ?? false;
  late final address = config<String?>('address');
  late final port = config<int?>('port') ?? 9090;
  late final path = config<String?>('path') ?? '/metrics';
  late final enableDartTimeline = config<bool?>('enableDartTimeline') ?? true;
  late final HttpServer _server;

  final _collectors = Set<MetricCollector>();
  final _metrics = <String, Metric>{};
  final _tracers = <String, Tracer>{};

  late final Tracer defaultTracer;
  final _scrapeMetric = GaugeMetric('datahub_instrumentation_scrape_duration');

  @override
  Future<void> initialize() async {
    if (enableEndpoint) {
      final serveAddress =
          nullOrWhitespace(address) ? io.InternetAddress.anyIPv4 : address;
      final socket = await io.ServerSocket.bind(serveAddress, port);

      _server = HttpServer(
        socket,
        _handleRequest,
        _onSocketError,
        _onProtocolError,
        _onStreamError,
      );
    }

    defaultTracer = getTracer(resolve<ConfigService>().serviceName, '1');
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

  /// Collects all current values of metrics into [SampleGroup]s with
  /// [MetricSample]s.
  List<SampleGroup> scrape() {
    final samples = <SampleGroup>[];
    _scrapeMetric.measureDuration(() {
      for (final _metric in _metrics.values) {
        samples.add(_metric.collect());
      }
      for (final collector in _collectors) {
        samples.add(collector.collect());
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
    Map<String, dynamic> attributes,
    FutureOr<R> Function() delegate,
  ) async {
    return await defaultTracer.trace(name, attributes, delegate);
  }

  Tracer getTracer(String name, String version) {
    final key = Tracer.buildKey(name, version);
    return _tracers[key] ??= Tracer(
      name: name,
      version: version,
      enableDartTimeline: true,
    );
  }

  Future<HttpResponse> _handleRequest(HttpRequest httpRequest) async {
    if (httpRequest.method != ApiRequestMethod.GET) {
      return HttpResponse(
        httpRequest.requestUri,
        io.HttpStatus.methodNotAllowed,
        {},
        Stream.empty(),
      );
    }

    if (httpRequest.path != path) {
      return HttpResponse(
        httpRequest.requestUri,
        io.HttpStatus.notFound,
        {},
        Stream.empty(),
      );
    }

    return await _scrapeRequest(httpRequest);
  }

  HttpResponse _scrapeRequest(HttpRequest httpRequest) {
    try {
      return _bridge.createResponse(httpRequest, scrape());
    } catch (e, stack) {
      final logService = resolve<LogService?>();
      if (logService != null) {
        logService.error('Error while collecting metrics.',
            error: e, trace: stack);
      } else {
        print('Error while collecting metrics.\n$e');
      }

      return HttpResponse(httpRequest.requestUri, 500, {}, Stream.empty());
    }
  }

  void _onSocketError(dynamic e, StackTrace? trace) {
    resolve<LogService>().error(
      'Error while listening to socket.',
      sender: 'DataHub',
      error: e,
      trace: trace,
    );
  }

  void _onProtocolError(dynamic e, StackTrace? trace) {
    resolve<LogService>().warn(
      'Error during protocol negotiation.',
      sender: 'DataHub',
      error: e,
      trace: trace,
    );
  }

  void _onStreamError(dynamic e, StackTrace? trace) {
    resolve<LogService>().verbose(
      'Error while handling HTTP2 stream.\n$e',
      sender: 'DataHub',
    );
  }

  @override
  Future<void> shutdown() async {
    if (enableEndpoint) {
      await _server.close();
    }
  }
}
