import 'dart:convert';
import 'dart:io';

import 'package:datahub/utils.dart';

import 'log_exporter.dart';
import 'log_record.dart';
import 'log_message.dart';

// TODO implement export to collector endpoints
class OpenTelemetryLogExporter implements LogExporter {
  final Map<String, dynamic> resourceAttributes;

  OpenTelemetryLogExporter({required this.resourceAttributes});

  @override
  void add(LogMessage message) {
    try {
      stdout.writeln(
        jsonEncode(
          LogRecord(
            body: message.line,
            timestamp: message.timestamp.nanosecondsSinceEpoch,
            resource: resourceAttributes,
            severityText: message.level.name,
            severityNumber: message.level.severityNumber,
            traceId: message.span?.traceId.hexId,
            spanId: message.span?.spanId.hexId,
          ).toJson(),
        ),
      );
    } catch (e) {
      stdout.writeln(e.toString());
      stdout.writeln(message.line);
    }
  }

  @override
  void close() {}
}
