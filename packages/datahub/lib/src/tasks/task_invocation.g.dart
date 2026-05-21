// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_invocation.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $TaskInvocation with DataObject<TaskInvocation> {
  const $TaskInvocation();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<TaskInvocation, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id(auto: true)],
  );

  static final $taskId = DataField<TaskInvocation, String>(
    name: 'taskId',
    valueOf: (p) => p.taskId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $state = DataField<TaskInvocation, TaskState>(
    name: 'state',
    valueOf: (p) => p.state,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, TaskState.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: TaskState.values)],
  );

  static final $parameters = DataField<TaskInvocation, Map<String, dynamic>>(
    name: 'parameters',
    valueOf: (p) => p.parameters,
    fromJson: (value, {String? name}) =>
        $$codec.decodeMap<dynamic>(value, $$codec.decodeDynamic, name: name),
    toJson: (value) => $$codec.encodeMap<dynamic>(value, $$codec.encodeDynamic),
  );

  static final $scheduledAt = DataField<TaskInvocation, DateTime>(
    name: 'scheduledAt',
    valueOf: (p) => p.scheduledAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final $scheduledFor = DataField<TaskInvocation, DateTime>(
    name: 'scheduledFor',
    valueOf: (p) => p.scheduledFor,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final $lastHeartbeat = DataField<TaskInvocation, DateTime?>(
    name: 'lastHeartbeat',
    valueOf: (p) => p.lastHeartbeat,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $progress = DataField<TaskInvocation, double>(
    name: 'progress',
    valueOf: (p) => p.progress,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
  );

  static final $startedAt = DataField<TaskInvocation, DateTime?>(
    name: 'startedAt',
    valueOf: (p) => p.startedAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $messages = DataField<TaskInvocation, List<String>>(
    name: 'messages',
    valueOf: (p) => p.messages,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $finishedAt = DataField<TaskInvocation, DateTime?>(
    name: 'finishedAt',
    valueOf: (p) => p.finishedAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final DataBean<TaskInvocation> bean = DataBean<TaskInvocation>(
    name: 'TaskInvocation',
    fields: List<DataField<TaskInvocation, dynamic>>.unmodifiable([
      $id,
      $taskId,
      $state,
      $parameters,
      $scheduledAt,
      $scheduledFor,
      $lastHeartbeat,
      $progress,
      $startedAt,
      $messages,
      $finishedAt,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<TaskInvocation, dynamic>> get $$fields => bean.fields;
  TaskInvocation copyWith({
    String? id,
    String? taskId,
    TaskState? state,
    Map<String, dynamic>? parameters,
    DateTime? scheduledAt,
    DateTime? scheduledFor,
    DateTime? lastHeartbeat,
    bool nullLastHeartbeat = false,
    double? progress,
    DateTime? startedAt,
    bool nullStartedAt = false,
    List<String>? messages,
    DateTime? finishedAt,
    bool nullFinishedAt = false,
  }) {
    final $data = this as TaskInvocation;
    return TaskInvocation(
      id: id ?? $data.id,
      taskId: taskId ?? $data.taskId,
      state: state ?? $data.state,
      parameters: parameters ?? $data.parameters,
      scheduledAt: scheduledAt ?? $data.scheduledAt,
      scheduledFor: scheduledFor ?? $data.scheduledFor,
      lastHeartbeat: nullLastHeartbeat
          ? null
          : (lastHeartbeat ?? $data.lastHeartbeat),
      progress: progress ?? $data.progress,
      startedAt: nullStartedAt ? null : (startedAt ?? $data.startedAt),
      messages: messages ?? $data.messages,
      finishedAt: nullFinishedAt ? null : (finishedAt ?? $data.finishedAt),
    );
  }

  static TaskInvocation fromValues(Map<String, dynamic> data) {
    return TaskInvocation(
      id: data['id'],
      taskId: data['taskId'],
      state: data['state'],
      parameters: data['parameters'],
      scheduledAt: data['scheduledAt'],
      scheduledFor: data['scheduledFor'],
      lastHeartbeat: data['lastHeartbeat'],
      progress: data['progress'],
      startedAt: data['startedAt'],
      messages: data['messages']?.cast<String>().toList(growable: false),
      finishedAt: data['finishedAt'],
    );
  }

  static TaskInvocation fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(TaskInvocation, data.runtimeType, name);
    }
    return TaskInvocation(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      taskId: $taskId.fromJson(
        data['taskId'],
        name: DataCodec.childName(name, 'taskId'),
      ),
      state: $state.fromJson(
        data['state'],
        name: DataCodec.childName(name, 'state'),
      ),
      parameters: $parameters.fromJson(
        data['parameters'],
        name: DataCodec.childName(name, 'parameters'),
      ),
      scheduledAt: $scheduledAt.fromJson(
        data['scheduledAt'],
        name: DataCodec.childName(name, 'scheduledAt'),
      ),
      scheduledFor: $scheduledFor.fromJson(
        data['scheduledFor'],
        name: DataCodec.childName(name, 'scheduledFor'),
      ),
      lastHeartbeat: $lastHeartbeat.fromJson(
        data['lastHeartbeat'],
        name: DataCodec.childName(name, 'lastHeartbeat'),
      ),
      progress: $progress.fromJson(
        data['progress'],
        name: DataCodec.childName(name, 'progress'),
      ),
      startedAt: $startedAt.fromJson(
        data['startedAt'],
        name: DataCodec.childName(name, 'startedAt'),
      ),
      messages: $messages.fromJson(
        data['messages'],
        name: DataCodec.childName(name, 'messages'),
      ),
      finishedAt: $finishedAt.fromJson(
        data['finishedAt'],
        name: DataCodec.childName(name, 'finishedAt'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as TaskInvocation;
    return {
      'id': $id.toJson($$data.id),
      'taskId': $taskId.toJson($$data.taskId),
      'state': $state.toJson($$data.state),
      'parameters': $parameters.toJson($$data.parameters),
      'scheduledAt': $scheduledAt.toJson($$data.scheduledAt),
      'scheduledFor': $scheduledFor.toJson($$data.scheduledFor),
      'lastHeartbeat': $lastHeartbeat.toJson($$data.lastHeartbeat),
      'progress': $progress.toJson($$data.progress),
      'startedAt': $startedAt.toJson($$data.startedAt),
      'messages': $messages.toJson($$data.messages),
      'finishedAt': $finishedAt.toJson($$data.finishedAt),
    }..removeWhere((k, v) => v == null);
  }
}
