import 'dart:convert';
import 'dart:io' as io;
import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:datahub/utils.dart';

import 'metrics_exporter.dart';

// Could be a Service...
//TODO docs
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
          buffer.write('{' +
              sample.labels.entries
                  .map((e) => '${e.key}="${e.value}"')
                  .join(',') +
              '}');
        }
        buffer.write(' ${sample.value}');
        buffer.write(' ${sample.timestamp.millisecondsSinceEpoch}');
        buffer.writeln();
      }
      buffer.writeln();
    }

    return HttpResponse(
      request.requestUri,
      200,
      {
        HttpHeaders.contentType: [Mime.plainText, 'version=0.0.4'],
      },
      Stream.value(utf8.encode(buffer.toString())),
    );
  }

  String formatTimestamp(DateTime timestamp) =>
      timestamp.millisecondsSinceEpoch.toString();

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

    try {
      return createResponse(httpRequest, await onScrape());
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
    await _server.close();
  }
}
