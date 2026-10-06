import 'dart:convert';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:datahub/http.dart';
import 'package:datahub/utils.dart';

import '../logs/log_helper.dart';
import 'metrics_exporter.dart';
import 'sample_group.dart';

/// Serves the metrics in the
/// [Prometheus text-based format](https://prometheus.io/docs/instrumenting/exposition_formats/#text-based-format).
///
/// Scrapes are not traced.
class PrometheusExporter extends MetricsExporter {
  late final HttpServer _server;

  final String? address;
  final int port;
  final String path;

  PrometheusExporter({
    required this.address,
    required this.port,
    required this.path,
    required super.onScrape,
  });

  @override
  Future<void> initialize() async {
    _server = HttpServer(
      await io.ServerSocket.bind(
        nullOrWhitespace(address) ? io.InternetAddress.anyIPv4 : address,
        port,
      ),
      _handleRequest,
      _onSocketError,
      _onProtocolError,
      _onStreamError,
      enableTracing: false,
    );
  }

  HttpResponse createResponse(
    HttpRequest request,
    List<SampleGroup> sampleGroups,
  ) {
    final buffer = StringBuffer();

    for (final group in sampleGroups) {
      if (group.metric.help != null) {
        buffer.writeln('# HELP ${group.metric.name} ${group.metric.help}');
      }
      buffer.writeln('# TYPE ${group.metric.name} ${group.metric.type.name}');
      for (final sample in group.samples) {
        buffer.write(sample.name);
        if (sample.labels.isNotEmpty) {
          buffer.write(
            '{${sample.labels.entries.map((e) => '${e.key}="${_escapeLabelValue(e.value)}"').join(',')}}',
          );
        }
        // timestamps are left out, since the scrape time is the time of
        // the values
        buffer.writeln(' ${formatValue(sample.value)}');
      }
      buffer.writeln();
    }

    return HttpResponse(request.requestUri, 200, {
      HttpHeaders.contentType: [
        '${Mime.plainText}; version=0.0.4; charset=utf-8',
      ],
    }, Stream.value(utf8.encode(buffer.toString())));
  }

  /// Escapes a label value as required by the text exposition format.
  static String _escapeLabelValue(String value) => value
      .replaceAll('\\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll('\n', r'\n');

  String formatValue(num value) {
    return switch (value) {
      double.infinity => '+Inf',
      double.negativeInfinity => '-Inf',
      double d when d.isNaN => 'NaN',
      double d => d.toString(),
      int i => i.toString(),
    };
  }

  Future<HttpResponse> _handleRequest(HttpRequest httpRequest) async {
    if (httpRequest.method != HttpRequestMethod.get) {
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

    try {
      return createResponse(httpRequest, await onScrape());
    } catch (e, stack) {
      log.error('Error while collecting metrics.', error: e, stack: stack);

      return HttpResponse(httpRequest.requestUri, 500, {}, Stream.empty());
    }
  }

  void _onSocketError(dynamic e, StackTrace? trace) {
    log.error('Error while listening to socket.', error: e, stack: trace);
  }

  void _onProtocolError(dynamic e, StackTrace? trace) {
    log.warn('Error during protocol negotiation.', error: e, stack: trace);
  }

  void _onStreamError(dynamic e, StackTrace? trace) {
    log.debug('Error while handling HTTP2 stream.', error: e, stack: trace);
  }

  @override
  Future<void> shutdown() async {
    await _server.close();
  }
}
