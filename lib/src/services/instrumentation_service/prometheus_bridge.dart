import 'dart:convert';

import 'package:datahub/http.dart';
import 'package:datahub/utils.dart';

import 'metric_sample.dart';

abstract class MetricBridge {
  HttpResponse createResponse(
      HttpRequest request, List<SampleGroup> sampleGroups);
}

class PrometheusBridge extends MetricBridge {
  @override
  HttpResponse createResponse(
      HttpRequest request, List<SampleGroup> sampleGroups) {
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
}
