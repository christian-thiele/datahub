import 'package:datahub/data.dart';

part 'log_record.g.dart';

@Data()
class LogRecord extends $LogRecord {
  final int? timestamp;
  final int? observedTimestamp;
  final String? traceId;
  final String? spanId;
  final int? traceFlags;
  final String? severityText;
  final int? severityNumber;

  final String? body;
  final Map<String, dynamic>? resource;
  final Map<String, dynamic>? instrumentationScope;
  final Map<String, dynamic>? attributes;
  final String? eventName;

  const LogRecord({
    this.timestamp,
    this.observedTimestamp,
    this.traceId,
    this.spanId,
    this.traceFlags,
    this.severityText,
    this.severityNumber,
    this.body,
    this.resource,
    this.instrumentationScope,
    this.attributes,
    this.eventName,
  });
}
