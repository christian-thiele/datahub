// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_record.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ScheduleRecord with DataObject<ScheduleRecord> {
  const $ScheduleRecord();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<ScheduleRecord, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id()],
  );

  static final $nextRunAt = DataField<ScheduleRecord, DateTime>(
    name: 'nextRunAt',
    valueOf: (p) => p.nextRunAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final $lastScheduledFor = DataField<ScheduleRecord, DateTime?>(
    name: 'lastScheduledFor',
    valueOf: (p) => p.lastScheduledFor,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $lastStartedAt = DataField<ScheduleRecord, DateTime?>(
    name: 'lastStartedAt',
    valueOf: (p) => p.lastStartedAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $lastFinishedAt = DataField<ScheduleRecord, DateTime?>(
    name: 'lastFinishedAt',
    valueOf: (p) => p.lastFinishedAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $lastError = DataField<ScheduleRecord, String?>(
    name: 'lastError',
    valueOf: (p) => p.lastError,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $lastMessages = DataField<ScheduleRecord, List<String>>(
    name: 'lastMessages',
    valueOf: (p) => p.lastMessages,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final DataBean<ScheduleRecord> bean = DataBean<ScheduleRecord>(
    name: 'ScheduleRecord',
    fields: List<DataField<ScheduleRecord, dynamic>>.unmodifiable([
      $id,
      $nextRunAt,
      $lastScheduledFor,
      $lastStartedAt,
      $lastFinishedAt,
      $lastError,
      $lastMessages,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ScheduleRecord, dynamic>> get $$fields => bean.fields;
  ScheduleRecord copyWith({
    String? id,
    DateTime? nextRunAt,
    DateTime? lastScheduledFor,
    bool nullLastScheduledFor = false,
    DateTime? lastStartedAt,
    bool nullLastStartedAt = false,
    DateTime? lastFinishedAt,
    bool nullLastFinishedAt = false,
    String? lastError,
    bool nullLastError = false,
    List<String>? lastMessages,
  }) {
    final $data = this as ScheduleRecord;
    return ScheduleRecord(
      id: id ?? $data.id,
      nextRunAt: nextRunAt ?? $data.nextRunAt,
      lastScheduledFor: nullLastScheduledFor
          ? null
          : (lastScheduledFor ?? $data.lastScheduledFor),
      lastStartedAt: nullLastStartedAt
          ? null
          : (lastStartedAt ?? $data.lastStartedAt),
      lastFinishedAt: nullLastFinishedAt
          ? null
          : (lastFinishedAt ?? $data.lastFinishedAt),
      lastError: nullLastError ? null : (lastError ?? $data.lastError),
      lastMessages: lastMessages ?? $data.lastMessages,
    );
  }

  static ScheduleRecord fromValues(Map<String, dynamic> data) {
    return ScheduleRecord(
      id: data['id'],
      nextRunAt: data['nextRunAt'],
      lastScheduledFor: data['lastScheduledFor'],
      lastStartedAt: data['lastStartedAt'],
      lastFinishedAt: data['lastFinishedAt'],
      lastError: data['lastError'],
      lastMessages:
          data['lastMessages']?.cast<String>().toList(growable: false) ??
          const [],
    );
  }

  static ScheduleRecord fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ScheduleRecord, data.runtimeType, name);
    }
    return ScheduleRecord(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      nextRunAt: $nextRunAt.fromJson(
        data['nextRunAt'],
        name: DataCodec.childName(name, 'nextRunAt'),
      ),
      lastScheduledFor: $lastScheduledFor.fromJson(
        data['lastScheduledFor'],
        name: DataCodec.childName(name, 'lastScheduledFor'),
      ),
      lastStartedAt: $lastStartedAt.fromJson(
        data['lastStartedAt'],
        name: DataCodec.childName(name, 'lastStartedAt'),
      ),
      lastFinishedAt: $lastFinishedAt.fromJson(
        data['lastFinishedAt'],
        name: DataCodec.childName(name, 'lastFinishedAt'),
      ),
      lastError: $lastError.fromJson(
        data['lastError'],
        name: DataCodec.childName(name, 'lastError'),
      ),
      lastMessages: $lastMessages.fromJson(
        data['lastMessages'],
        name: DataCodec.childName(name, 'lastMessages'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ScheduleRecord;
    return {
      'id': $id.toJson($$data.id),
      'nextRunAt': $nextRunAt.toJson($$data.nextRunAt),
      'lastScheduledFor': $lastScheduledFor.toJson($$data.lastScheduledFor),
      'lastStartedAt': $lastStartedAt.toJson($$data.lastStartedAt),
      'lastFinishedAt': $lastFinishedAt.toJson($$data.lastFinishedAt),
      'lastError': $lastError.toJson($$data.lastError),
      'lastMessages': $lastMessages.toJson($$data.lastMessages),
    }..removeWhere((k, v) => v == null);
  }
}
