// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_history_entry.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $WorkflowHistoryEntry
    with DataObject<WorkflowHistoryEntry> {
  const $WorkflowHistoryEntry();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<WorkflowHistoryEntry, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString((value ?? ''), name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id(auto: true)],
  );

  static final $workflow = DataField<WorkflowHistoryEntry, String>(
    name: 'workflow',
    valueOf: (p) => p.workflow,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $elementId = DataField<WorkflowHistoryEntry, String>(
    name: 'elementId',
    valueOf: (p) => p.elementId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $timestamp = DataField<WorkflowHistoryEntry, DateTime>(
    name: 'timestamp',
    valueOf: (p) => p.timestamp,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final $kind = DataField<WorkflowHistoryEntry, WorkflowHistoryKind>(
    name: 'kind',
    valueOf: (p) => p.kind,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, WorkflowHistoryKind.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: WorkflowHistoryKind.values)],
  );

  static final $step = DataField<WorkflowHistoryEntry, String?>(
    name: 'step',
    valueOf: (p) => p.step,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $eventId = DataField<WorkflowHistoryEntry, String?>(
    name: 'eventId',
    valueOf: (p) => p.eventId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $attempt = DataField<WorkflowHistoryEntry, int?>(
    name: 'attempt',
    valueOf: (p) => p.attempt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $state = DataField<WorkflowHistoryEntry, String?>(
    name: 'state',
    valueOf: (p) => p.state,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $newState = DataField<WorkflowHistoryEntry, String?>(
    name: 'newState',
    valueOf: (p) => p.newState,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $changes =
      DataField<WorkflowHistoryEntry, Map<String, dynamic>?>(
        name: 'changes',
        valueOf: (p) => p.changes,
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

  static final $signal = DataField<WorkflowHistoryEntry, Map<String, dynamic>?>(
    name: 'signal',
    valueOf: (p) => p.signal,
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

  static final $error = DataField<WorkflowHistoryEntry, String?>(
    name: 'error',
    valueOf: (p) => p.error,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $nextAttemptAt = DataField<WorkflowHistoryEntry, DateTime?>(
    name: 'nextAttemptAt',
    valueOf: (p) => p.nextAttemptAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $messages = DataField<WorkflowHistoryEntry, List<String>>(
    name: 'messages',
    valueOf: (p) => p.messages,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final DataBean<WorkflowHistoryEntry> bean =
      DataBean<WorkflowHistoryEntry>(
        name: 'WorkflowHistoryEntry',
        fields: List<DataField<WorkflowHistoryEntry, dynamic>>.unmodifiable([
          $id,
          $workflow,
          $elementId,
          $timestamp,
          $kind,
          $step,
          $eventId,
          $attempt,
          $state,
          $newState,
          $changes,
          $signal,
          $error,
          $nextAttemptAt,
          $messages,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<WorkflowHistoryEntry, dynamic>> get $$fields => bean.fields;
  WorkflowHistoryEntry copyWith({
    String? id,
    String? workflow,
    String? elementId,
    DateTime? timestamp,
    WorkflowHistoryKind? kind,
    String? step,
    bool nullStep = false,
    String? eventId,
    bool nullEventId = false,
    int? attempt,
    bool nullAttempt = false,
    String? state,
    bool nullState = false,
    String? newState,
    bool nullNewState = false,
    Map<String, dynamic>? changes,
    bool nullChanges = false,
    Map<String, dynamic>? signal,
    bool nullSignal = false,
    String? error,
    bool nullError = false,
    DateTime? nextAttemptAt,
    bool nullNextAttemptAt = false,
    List<String>? messages,
  }) {
    final $data = this as WorkflowHistoryEntry;
    return WorkflowHistoryEntry(
      id: id ?? $data.id,
      workflow: workflow ?? $data.workflow,
      elementId: elementId ?? $data.elementId,
      timestamp: timestamp ?? $data.timestamp,
      kind: kind ?? $data.kind,
      step: nullStep ? null : (step ?? $data.step),
      eventId: nullEventId ? null : (eventId ?? $data.eventId),
      attempt: nullAttempt ? null : (attempt ?? $data.attempt),
      state: nullState ? null : (state ?? $data.state),
      newState: nullNewState ? null : (newState ?? $data.newState),
      changes: nullChanges ? null : (changes ?? $data.changes),
      signal: nullSignal ? null : (signal ?? $data.signal),
      error: nullError ? null : (error ?? $data.error),
      nextAttemptAt: nullNextAttemptAt
          ? null
          : (nextAttemptAt ?? $data.nextAttemptAt),
      messages: messages ?? $data.messages,
    );
  }

  static WorkflowHistoryEntry fromValues(Map<String, dynamic> data) {
    return WorkflowHistoryEntry(
      id: data['id'] ?? '',
      workflow: data['workflow'],
      elementId: data['elementId'],
      timestamp: data['timestamp'],
      kind: data['kind'],
      step: data['step'],
      eventId: data['eventId'],
      attempt: data['attempt'],
      state: data['state'],
      newState: data['newState'],
      changes: data['changes'],
      signal: data['signal'],
      error: data['error'],
      nextAttemptAt: data['nextAttemptAt'],
      messages:
          data['messages']?.cast<String>().toList(growable: false) ?? const [],
    );
  }

  static WorkflowHistoryEntry fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        WorkflowHistoryEntry,
        data.runtimeType,
        name,
      );
    }
    return WorkflowHistoryEntry(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      workflow: $workflow.fromJson(
        data['workflow'],
        name: DataCodec.childName(name, 'workflow'),
      ),
      elementId: $elementId.fromJson(
        data['elementId'],
        name: DataCodec.childName(name, 'elementId'),
      ),
      timestamp: $timestamp.fromJson(
        data['timestamp'],
        name: DataCodec.childName(name, 'timestamp'),
      ),
      kind: $kind.fromJson(
        data['kind'],
        name: DataCodec.childName(name, 'kind'),
      ),
      step: $step.fromJson(
        data['step'],
        name: DataCodec.childName(name, 'step'),
      ),
      eventId: $eventId.fromJson(
        data['eventId'],
        name: DataCodec.childName(name, 'eventId'),
      ),
      attempt: $attempt.fromJson(
        data['attempt'],
        name: DataCodec.childName(name, 'attempt'),
      ),
      state: $state.fromJson(
        data['state'],
        name: DataCodec.childName(name, 'state'),
      ),
      newState: $newState.fromJson(
        data['newState'],
        name: DataCodec.childName(name, 'newState'),
      ),
      changes: $changes.fromJson(
        data['changes'],
        name: DataCodec.childName(name, 'changes'),
      ),
      signal: $signal.fromJson(
        data['signal'],
        name: DataCodec.childName(name, 'signal'),
      ),
      error: $error.fromJson(
        data['error'],
        name: DataCodec.childName(name, 'error'),
      ),
      nextAttemptAt: $nextAttemptAt.fromJson(
        data['nextAttemptAt'],
        name: DataCodec.childName(name, 'nextAttemptAt'),
      ),
      messages: $messages.fromJson(
        data['messages'],
        name: DataCodec.childName(name, 'messages'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as WorkflowHistoryEntry;
    return {
      'id': $id.toJson($$data.id),
      'workflow': $workflow.toJson($$data.workflow),
      'elementId': $elementId.toJson($$data.elementId),
      'timestamp': $timestamp.toJson($$data.timestamp),
      'kind': $kind.toJson($$data.kind),
      'step': $step.toJson($$data.step),
      'eventId': $eventId.toJson($$data.eventId),
      'attempt': $attempt.toJson($$data.attempt),
      'state': $state.toJson($$data.state),
      'newState': $newState.toJson($$data.newState),
      'changes': $changes.toJson($$data.changes),
      'signal': $signal.toJson($$data.signal),
      'error': $error.toJson($$data.error),
      'nextAttemptAt': $nextAttemptAt.toJson($$data.nextAttemptAt),
      'messages': $messages.toJson($$data.messages),
    }..removeWhere((k, v) => v == null);
  }
}
