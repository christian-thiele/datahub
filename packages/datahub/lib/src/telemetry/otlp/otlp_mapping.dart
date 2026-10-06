import 'dart:convert';
import 'dart:typed_data';

import 'package:datahub/utils.dart';
import 'package:fixnum/fixnum.dart';

import '../logs/log_message.dart';
import '../opentelemetry-dart/open_telemetry.dart' as otel;
import '../telemetry_scope.dart';
import '../trace/event.dart';
import '../trace/span.dart';

/// Conversion of spans, logs and attributes to OTLP messages.

otel.ExportTraceServiceRequest otlpTraceRequest(
  Map<String, Object?> resourceAttributes,
  Iterable<LocalSpan> spans,
) {
  final scopes = <String, (TelemetryScope, List<otel.Span>)>{};
  for (final span in spans) {
    scopes
        .putIfAbsent(span.tracer.key, () => (span.tracer, []))
        .$2
        .add(otlpSpan(span));
  }

  return otel.ExportTraceServiceRequest(
    resourceSpans: [
      otel.ResourceSpans(
        resource: otlpResource(resourceAttributes),
        scopeSpans: [
          for (final (scope, spans) in scopes.values)
            otel.ScopeSpans(scope: otlpScope(scope), spans: spans),
        ],
      ),
    ],
  );
}

otel.ExportLogsServiceRequest otlpLogsRequest(
  Map<String, Object?> resourceAttributes,
  TelemetryScope scope,
  Iterable<LogMessage> messages,
) {
  return otel.ExportLogsServiceRequest(
    resourceLogs: [
      otel.ResourceLogs(
        resource: otlpResource(resourceAttributes),
        scopeLogs: [
          otel.ScopeLogs(
            scope: otlpScope(scope),
            logRecords: messages.map(otlpLogRecord),
          ),
        ],
      ),
    ],
  );
}

otel.Resource otlpResource(Map<String, Object?> attributes) =>
    otel.Resource(attributes: otlpAttributes(attributes));

otel.InstrumentationScope otlpScope(TelemetryScope scope) =>
    otel.InstrumentationScope(
      name: scope.name,
      version: scope.version,
      attributes: otlpAttributes(scope.attributes),
    );

/// A span, which may still be running (no end time).
///
/// The status is `ERROR` if the span failed and `UNSET` otherwise, as
/// instrumentation should not set `OK`.
otel.Span otlpSpan(LocalSpan span) {
  return otel.Span(
    name: span.name,
    traceId: span.traceId.bytes,
    spanId: span.spanId.bytes,
    parentSpanId: span.parentSpanId?.bytes,
    flags: span.traceFlags,
    kind: otlpSpanKind(span.type),
    status: span.hasError
        ? otel.Status(
            code: otel.Status_StatusCode.STATUS_CODE_ERROR,
            message: span.errorDescription,
          )
        : otel.Status(code: otel.Status_StatusCode.STATUS_CODE_UNSET),
    startTimeUnixNano: span.startTimestamp?.nanosecondsSinceEpochInt64,
    endTimeUnixNano: span.endTimestamp?.nanosecondsSinceEpochInt64,
    attributes: otlpAttributes(span.attributes),
    events: span.events.map(otlpSpanEvent),
  );
}

otel.Span_Event otlpSpanEvent(Event event) => otel.Span_Event(
  name: event.name,
  timeUnixNano: event.timestamp.nanosecondsSinceEpochInt64,
  attributes: otlpAttributes(event.attributes),
);

otel.Span_SpanKind otlpSpanKind(SpanType? type) => switch (type) {
  SpanType.internal => otel.Span_SpanKind.SPAN_KIND_INTERNAL,
  SpanType.server => otel.Span_SpanKind.SPAN_KIND_SERVER,
  SpanType.client => otel.Span_SpanKind.SPAN_KIND_CLIENT,
  SpanType.producer => otel.Span_SpanKind.SPAN_KIND_PRODUCER,
  SpanType.consumer => otel.Span_SpanKind.SPAN_KIND_CONSUMER,
  null => otel.Span_SpanKind.SPAN_KIND_UNSPECIFIED,
};

/// A log record. Labels become attributes, the error and stack trace of
/// [message] the `exception.*` attributes of the semantic conventions.
otel.LogRecord otlpLogRecord(LogMessage message) {
  final time = message.timestamp.nanosecondsSinceEpochInt64;
  final span = message.span;
  return otel.LogRecord(
    timeUnixNano: time,
    observedTimeUnixNano: time,
    severityNumber: otel.SeverityNumber.valueOf(message.level.severityNumber),
    severityText: message.level.severityText,
    body: otel.AnyValue(stringValue: message.line),
    attributes: otlpAttributes({
      ...message.labels,
      if (message.error case final Object error) ...{
        'exception.type': error.runtimeType.toString(),
        'exception.message': ExceptionEvent.messageOf(error),
      },
      if (message.stack case final stack?)
        'exception.stacktrace': stack.toString(),
    }),
    traceId: span?.traceId.bytes,
    spanId: span?.spanId.bytes,
    flags: span?.traceFlags,
  );
}

/// Attributes with null values are left out.
List<otel.KeyValue> otlpAttributes(Map<String, Object?> attributes) => [
  for (final MapEntry(:key, :value) in attributes.entries)
    if (value != null) otel.KeyValue(key: key, value: otlpValue(value)),
];

/// Converts [value] to an attribute value. Only [Uint8List]s are bytes,
/// other lists are arrays and maps are encoded as JSON strings, since
/// attributes of spans and logs should not be nested.
otel.AnyValue otlpValue(Object? value) {
  return switch (value) {
    null => otel.AnyValue(),
    String v => otel.AnyValue(stringValue: v),
    bool v => otel.AnyValue(boolValue: v),
    int v => otel.AnyValue(intValue: Int64(v)),
    Int64 v => otel.AnyValue(intValue: v),
    double v => otel.AnyValue(doubleValue: v),
    Uint8List v => otel.AnyValue(bytesValue: v),
    Iterable<Object?> v => otel.AnyValue(
      arrayValue: otel.ArrayValue(values: v.map(otlpValue)),
    ),
    Map v => otel.AnyValue(stringValue: _encodeJson(v)),
    Enum v => otel.AnyValue(stringValue: v.name),
    Object v => otel.AnyValue(stringValue: v.toString()),
  };
}

String _encodeJson(Object value) {
  try {
    return jsonEncode(value);
  } catch (_) {
    return value.toString();
  }
}
