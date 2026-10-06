// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_event.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $WorkflowEvent with DataObject<WorkflowEvent> {
  const $WorkflowEvent();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<WorkflowEvent, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString((value ?? ''), name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id(auto: true)],
  );

  static final $workflow = DataField<WorkflowEvent, String>(
    name: 'workflow',
    valueOf: (p) => p.workflow,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $elementId = DataField<WorkflowEvent, String>(
    name: 'elementId',
    valueOf: (p) => p.elementId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $step = DataField<WorkflowEvent, String>(
    name: 'step',
    valueOf: (p) => p.step,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $payload = DataField<WorkflowEvent, Map<String, dynamic>?>(
    name: 'payload',
    valueOf: (p) => p.payload,
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

  static final $createdAt = DataField<WorkflowEvent, DateTime>(
    name: 'createdAt',
    valueOf: (p) => p.createdAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final $dueAt = DataField<WorkflowEvent, DateTime>(
    name: 'dueAt',
    valueOf: (p) => p.dueAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final $expiresAt = DataField<WorkflowEvent, DateTime?>(
    name: 'expiresAt',
    valueOf: (p) => p.expiresAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $status = DataField<WorkflowEvent, WorkflowEventStatus>(
    name: 'status',
    valueOf: (p) => p.status,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? WorkflowEventStatus.pending),
      WorkflowEventStatus.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: WorkflowEventStatus.values)],
  );

  static final $attempts = DataField<WorkflowEvent, int>(
    name: 'attempts',
    valueOf: (p) => p.attempts,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $lastError = DataField<WorkflowEvent, String?>(
    name: 'lastError',
    valueOf: (p) => p.lastError,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $traceId = DataField<WorkflowEvent, String?>(
    name: 'traceId',
    valueOf: (p) => p.traceId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $spanId = DataField<WorkflowEvent, String?>(
    name: 'spanId',
    valueOf: (p) => p.spanId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $startedAt = DataField<WorkflowEvent, DateTime?>(
    name: 'startedAt',
    valueOf: (p) => p.startedAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $heartbeatAt = DataField<WorkflowEvent, DateTime?>(
    name: 'heartbeatAt',
    valueOf: (p) => p.heartbeatAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $worker = DataField<WorkflowEvent, String?>(
    name: 'worker',
    valueOf: (p) => p.worker,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $messages = DataField<WorkflowEvent, List<String>>(
    name: 'messages',
    valueOf: (p) => p.messages,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final DataBean<WorkflowEvent> bean = DataBean<WorkflowEvent>(
    name: 'WorkflowEvent',
    fields: List<DataField<WorkflowEvent, dynamic>>.unmodifiable([
      $id,
      $workflow,
      $elementId,
      $step,
      $payload,
      $createdAt,
      $dueAt,
      $expiresAt,
      $status,
      $attempts,
      $lastError,
      $traceId,
      $spanId,
      $startedAt,
      $heartbeatAt,
      $worker,
      $messages,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<WorkflowEvent, dynamic>> get $$fields => bean.fields;
  WorkflowEvent copyWith({
    String? id,
    String? workflow,
    String? elementId,
    String? step,
    Map<String, dynamic>? payload,
    bool nullPayload = false,
    DateTime? createdAt,
    DateTime? dueAt,
    DateTime? expiresAt,
    bool nullExpiresAt = false,
    WorkflowEventStatus? status,
    int? attempts,
    String? lastError,
    bool nullLastError = false,
    String? traceId,
    bool nullTraceId = false,
    String? spanId,
    bool nullSpanId = false,
    DateTime? startedAt,
    bool nullStartedAt = false,
    DateTime? heartbeatAt,
    bool nullHeartbeatAt = false,
    String? worker,
    bool nullWorker = false,
    List<String>? messages,
  }) {
    final $data = this as WorkflowEvent;
    return WorkflowEvent(
      id: id ?? $data.id,
      workflow: workflow ?? $data.workflow,
      elementId: elementId ?? $data.elementId,
      step: step ?? $data.step,
      payload: nullPayload ? null : (payload ?? $data.payload),
      createdAt: createdAt ?? $data.createdAt,
      dueAt: dueAt ?? $data.dueAt,
      expiresAt: nullExpiresAt ? null : (expiresAt ?? $data.expiresAt),
      status: status ?? $data.status,
      attempts: attempts ?? $data.attempts,
      lastError: nullLastError ? null : (lastError ?? $data.lastError),
      traceId: nullTraceId ? null : (traceId ?? $data.traceId),
      spanId: nullSpanId ? null : (spanId ?? $data.spanId),
      startedAt: nullStartedAt ? null : (startedAt ?? $data.startedAt),
      heartbeatAt: nullHeartbeatAt ? null : (heartbeatAt ?? $data.heartbeatAt),
      worker: nullWorker ? null : (worker ?? $data.worker),
      messages: messages ?? $data.messages,
    );
  }

  static WorkflowEvent fromValues(Map<String, dynamic> data) {
    return WorkflowEvent(
      id: data['id'] ?? '',
      workflow: data['workflow'],
      elementId: data['elementId'],
      step: data['step'],
      payload: data['payload'],
      createdAt: data['createdAt'],
      dueAt: data['dueAt'],
      expiresAt: data['expiresAt'],
      status: data['status'] ?? WorkflowEventStatus.pending,
      attempts: data['attempts'] ?? 0,
      lastError: data['lastError'],
      traceId: data['traceId'],
      spanId: data['spanId'],
      startedAt: data['startedAt'],
      heartbeatAt: data['heartbeatAt'],
      worker: data['worker'],
      messages:
          data['messages']?.cast<String>().toList(growable: false) ?? const [],
    );
  }

  static WorkflowEvent fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(WorkflowEvent, data.runtimeType, name);
    }
    return WorkflowEvent(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      workflow: $workflow.fromJson(
        data['workflow'],
        name: DataCodec.childName(name, 'workflow'),
      ),
      elementId: $elementId.fromJson(
        data['elementId'],
        name: DataCodec.childName(name, 'elementId'),
      ),
      step: $step.fromJson(
        data['step'],
        name: DataCodec.childName(name, 'step'),
      ),
      payload: $payload.fromJson(
        data['payload'],
        name: DataCodec.childName(name, 'payload'),
      ),
      createdAt: $createdAt.fromJson(
        data['createdAt'],
        name: DataCodec.childName(name, 'createdAt'),
      ),
      dueAt: $dueAt.fromJson(
        data['dueAt'],
        name: DataCodec.childName(name, 'dueAt'),
      ),
      expiresAt: $expiresAt.fromJson(
        data['expiresAt'],
        name: DataCodec.childName(name, 'expiresAt'),
      ),
      status: $status.fromJson(
        data['status'],
        name: DataCodec.childName(name, 'status'),
      ),
      attempts: $attempts.fromJson(
        data['attempts'],
        name: DataCodec.childName(name, 'attempts'),
      ),
      lastError: $lastError.fromJson(
        data['lastError'],
        name: DataCodec.childName(name, 'lastError'),
      ),
      traceId: $traceId.fromJson(
        data['traceId'],
        name: DataCodec.childName(name, 'traceId'),
      ),
      spanId: $spanId.fromJson(
        data['spanId'],
        name: DataCodec.childName(name, 'spanId'),
      ),
      startedAt: $startedAt.fromJson(
        data['startedAt'],
        name: DataCodec.childName(name, 'startedAt'),
      ),
      heartbeatAt: $heartbeatAt.fromJson(
        data['heartbeatAt'],
        name: DataCodec.childName(name, 'heartbeatAt'),
      ),
      worker: $worker.fromJson(
        data['worker'],
        name: DataCodec.childName(name, 'worker'),
      ),
      messages: $messages.fromJson(
        data['messages'],
        name: DataCodec.childName(name, 'messages'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as WorkflowEvent;
    return {
      'id': $id.toJson($$data.id),
      'workflow': $workflow.toJson($$data.workflow),
      'elementId': $elementId.toJson($$data.elementId),
      'step': $step.toJson($$data.step),
      'payload': $payload.toJson($$data.payload),
      'createdAt': $createdAt.toJson($$data.createdAt),
      'dueAt': $dueAt.toJson($$data.dueAt),
      'expiresAt': $expiresAt.toJson($$data.expiresAt),
      'status': $status.toJson($$data.status),
      'attempts': $attempts.toJson($$data.attempts),
      'lastError': $lastError.toJson($$data.lastError),
      'traceId': $traceId.toJson($$data.traceId),
      'spanId': $spanId.toJson($$data.spanId),
      'startedAt': $startedAt.toJson($$data.startedAt),
      'heartbeatAt': $heartbeatAt.toJson($$data.heartbeatAt),
      'worker': $worker.toJson($$data.worker),
      'messages': $messages.toJson($$data.messages),
    }..removeWhere((k, v) => v == null);
  }
}
