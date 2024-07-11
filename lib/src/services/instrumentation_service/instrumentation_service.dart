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

export 'counter_metric.dart';
export 'gauge_metric.dart';
export 'histogram_metric.dart';

/// Internal service for collecting and exposing application metrics.
///
/// In terms of Prometheus conventions, this service provides the
/// "CollectorRegistry" and the "Bridge" to the Prometheus text based format.
///
/// Configuration values: (inside "datahub.metrics")
///   `endpointEnabled`: Enable prometheus text-based format endpoint (default false)
///   `address`: The address the HTTP-Server listens for, null means any (default null)
///   `port`: The port the HTTP-Server listens on (default 9090)
///   `path`: The path of the metrics endpoint (default "/metrics")
///
/// TODO instrumentation docs
class InstrumentationService extends BaseService {
  InstrumentationService() : super('datahub.metrics');

  final MetricBridge _bridge = PrometheusBridge();
  late final enableEndpoint = config<bool?>('enableEndpoint') ?? false;
  late final address = config<String?>('address');
  late final port = config<int?>('port') ?? 9090;
  late final path = config<String?>('path') ?? '/metrics';
  late final HttpServer _server;

  final _collectors = Set<MetricCollector>();
  final _metrics = <String, Metric>{};

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

  void registerCollector(MetricCollector metricCollector) {
    _collectors.add(metricCollector);
  }

  void unregisterCollector(MetricCollector metricCollector) {
    _collectors.remove(metricCollector);
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
