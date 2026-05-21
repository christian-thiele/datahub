import 'dart:io';

import 'package:boost/boost.dart';
import 'package:datahub/utils.dart';

import 'log_exporter.dart';
import 'log_message.dart';

class OpenTelemetryLogExporter implements LogExporter {
  final Map<String, dynamic> resourceAttributes;

  OpenTelemetryLogExporter({required this.resourceAttributes});

  @override
  void add(LogMessage message) {
    try {
      final body = {
        for (final (key, value) in message.labels.tuples) key: value,
        'severity': message.level.name.toUpperCase(),
        'msg': message.line,
      };

      /*
      final logRecord = LogRecord(
        body: jsonEncode(body),
        timestamp: message.timestamp.nanosecondsSinceEpoch,
        resource: resourceAttributes,
        severityText: message.level.name.toUpperCase(),
        severityNumber: message.level.severityNumber,
        traceId: message.span?.traceId.hexId,
        spanId: message.span?.spanId.hexId,
      );
      */

      // TODO implement export to collector endpoints

      stdout.writeln(logFmtEncode(body));
    } catch (e) {
      stdout.writeln(e.toString());
      stdout.writeln(message.line);
    }
  }

  @override
  void close() {}
}
