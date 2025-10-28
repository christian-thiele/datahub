// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_record.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $LogRecord with DataObject<LogRecord> {
  const $LogRecord();
  static const $$codec = JsonDataCodec();
  static final $timestamp = DataField<LogRecord, int?>(
    name: 'timestamp',
    valueOf: (p) => p.timestamp,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $observedTimestamp = DataField<LogRecord, int?>(
    name: 'observedTimestamp',
    valueOf: (p) => p.observedTimestamp,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $traceId = DataField<LogRecord, String?>(
    name: 'traceId',
    valueOf: (p) => p.traceId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $spanId = DataField<LogRecord, String?>(
    name: 'spanId',
    valueOf: (p) => p.spanId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $traceFlags = DataField<LogRecord, int?>(
    name: 'traceFlags',
    valueOf: (p) => p.traceFlags,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $severityText = DataField<LogRecord, String?>(
    name: 'severityText',
    valueOf: (p) => p.severityText,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $severityNumber = DataField<LogRecord, int?>(
    name: 'severityNumber',
    valueOf: (p) => p.severityNumber,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $body = DataField<LogRecord, String?>(
    name: 'body',
    valueOf: (p) => p.body,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $resource = DataField<LogRecord, Map<String, dynamic>?>(
    name: 'resource',
    valueOf: (p) => p.resource,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      (v, {String? name}) =>
          $$codec.decodeMap<dynamic>(v, $$codec.decodeDynamic, name: name),
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(
      value,
      (v) => $$codec.encodeMap<dynamic>(v, $$codec.encodeDynamic),
    ),
  );

  static final $instrumentationScope =
      DataField<LogRecord, Map<String, dynamic>?>(
        name: 'instrumentationScope',
        valueOf: (p) => p.instrumentationScope,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeMap<dynamic>(v, $$codec.decodeDynamic, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeMap<dynamic>(v, $$codec.encodeDynamic),
        ),
      );

  static final $attributes = DataField<LogRecord, Map<String, dynamic>?>(
    name: 'attributes',
    valueOf: (p) => p.attributes,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      (v, {String? name}) =>
          $$codec.decodeMap<dynamic>(v, $$codec.decodeDynamic, name: name),
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(
      value,
      (v) => $$codec.encodeMap<dynamic>(v, $$codec.encodeDynamic),
    ),
  );

  static final $eventName = DataField<LogRecord, String?>(
    name: 'eventName',
    valueOf: (p) => p.eventName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<LogRecord> bean = DataBean<LogRecord>(
    name: 'LogRecord',
    fields: List<DataField<LogRecord, dynamic>>.unmodifiable([
      $timestamp,
      $observedTimestamp,
      $traceId,
      $spanId,
      $traceFlags,
      $severityText,
      $severityNumber,
      $body,
      $resource,
      $instrumentationScope,
      $attributes,
      $eventName,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<LogRecord, dynamic>> get $$fields => bean.fields;
  LogRecord copyWith({
    int? timestamp,
    bool nullTimestamp = false,
    int? observedTimestamp,
    bool nullObservedTimestamp = false,
    String? traceId,
    bool nullTraceId = false,
    String? spanId,
    bool nullSpanId = false,
    int? traceFlags,
    bool nullTraceFlags = false,
    String? severityText,
    bool nullSeverityText = false,
    int? severityNumber,
    bool nullSeverityNumber = false,
    String? body,
    bool nullBody = false,
    Map<String, dynamic>? resource,
    bool nullResource = false,
    Map<String, dynamic>? instrumentationScope,
    bool nullInstrumentationScope = false,
    Map<String, dynamic>? attributes,
    bool nullAttributes = false,
    String? eventName,
    bool nullEventName = false,
  }) {
    final $data = this as LogRecord;
    return LogRecord(
      timestamp: nullTimestamp ? null : (timestamp ?? $data.timestamp),
      observedTimestamp: nullObservedTimestamp
          ? null
          : (observedTimestamp ?? $data.observedTimestamp),
      traceId: nullTraceId ? null : (traceId ?? $data.traceId),
      spanId: nullSpanId ? null : (spanId ?? $data.spanId),
      traceFlags: nullTraceFlags ? null : (traceFlags ?? $data.traceFlags),
      severityText: nullSeverityText
          ? null
          : (severityText ?? $data.severityText),
      severityNumber: nullSeverityNumber
          ? null
          : (severityNumber ?? $data.severityNumber),
      body: nullBody ? null : (body ?? $data.body),
      resource: nullResource ? null : (resource ?? $data.resource),
      instrumentationScope: nullInstrumentationScope
          ? null
          : (instrumentationScope ?? $data.instrumentationScope),
      attributes: nullAttributes ? null : (attributes ?? $data.attributes),
      eventName: nullEventName ? null : (eventName ?? $data.eventName),
    );
  }

  static LogRecord fromValues(Map<String, dynamic> data) {
    return LogRecord(
      timestamp: data['timestamp'],
      observedTimestamp: data['observedTimestamp'],
      traceId: data['traceId'],
      spanId: data['spanId'],
      traceFlags: data['traceFlags'],
      severityText: data['severityText'],
      severityNumber: data['severityNumber'],
      body: data['body'],
      resource: data['resource'],
      instrumentationScope: data['instrumentationScope'],
      attributes: data['attributes'],
      eventName: data['eventName'],
    );
  }

  static LogRecord fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(LogRecord, data.runtimeType, name);
    }
    return LogRecord(
      timestamp: $timestamp.fromJson(
        data['timestamp'],
        name: DataCodec.childName(name, 'timestamp'),
      ),
      observedTimestamp: $observedTimestamp.fromJson(
        data['observed_timestamp'],
        name: DataCodec.childName(name, 'observed_timestamp'),
      ),
      traceId: $traceId.fromJson(
        data['trace_id'],
        name: DataCodec.childName(name, 'trace_id'),
      ),
      spanId: $spanId.fromJson(
        data['span_id'],
        name: DataCodec.childName(name, 'span_id'),
      ),
      traceFlags: $traceFlags.fromJson(
        data['trace_flags'],
        name: DataCodec.childName(name, 'trace_flags'),
      ),
      severityText: $severityText.fromJson(
        data['severity_text'],
        name: DataCodec.childName(name, 'severity_text'),
      ),
      severityNumber: $severityNumber.fromJson(
        data['severity_number'],
        name: DataCodec.childName(name, 'severity_number'),
      ),
      body: $body.fromJson(
        data['body'],
        name: DataCodec.childName(name, 'body'),
      ),
      resource: $resource.fromJson(
        data['resource'],
        name: DataCodec.childName(name, 'resource'),
      ),
      instrumentationScope: $instrumentationScope.fromJson(
        data['instrumentation_scope'],
        name: DataCodec.childName(name, 'instrumentation_scope'),
      ),
      attributes: $attributes.fromJson(
        data['attributes'],
        name: DataCodec.childName(name, 'attributes'),
      ),
      eventName: $eventName.fromJson(
        data['event_name'],
        name: DataCodec.childName(name, 'event_name'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as LogRecord;
    return {
      'timestamp': $timestamp.toJson($$data.timestamp),
      'observed_timestamp': $observedTimestamp.toJson($$data.observedTimestamp),
      'trace_id': $traceId.toJson($$data.traceId),
      'span_id': $spanId.toJson($$data.spanId),
      'trace_flags': $traceFlags.toJson($$data.traceFlags),
      'severity_text': $severityText.toJson($$data.severityText),
      'severity_number': $severityNumber.toJson($$data.severityNumber),
      'body': $body.toJson($$data.body),
      'resource': $resource.toJson($$data.resource),
      'instrumentation_scope': $instrumentationScope.toJson(
        $$data.instrumentationScope,
      ),
      'attributes': $attributes.toJson($$data.attributes),
      'event_name': $eventName.toJson($$data.eventName),
    }..removeWhere((k, v) => v == null);
  }
}
