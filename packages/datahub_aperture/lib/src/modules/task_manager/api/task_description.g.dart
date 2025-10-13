// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_description.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $TaskDescription with DataObject<TaskDescription> {
  const $TaskDescription();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<TaskDescription, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const Id(),
    ],
  );

  static final $displayName = DataField<TaskDescription, String>(
    name: 'displayName',
    valueOf: (p) => p.displayName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $icon = DataField<TaskDescription, int>(
    name: 'icon',
    valueOf: (p) => p.icon,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final DataBean<TaskDescription> bean = DataBean<TaskDescription>(
    name: 'TaskDescription',
    fields: List<DataField<TaskDescription, dynamic>>.unmodifiable([
      $id,
      $displayName,
      $icon,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<TaskDescription, dynamic>> get $$fields => bean.fields;
  TaskDescription copyWith({
    String? id,
    String? displayName,
    int? icon,
  }) {
    final $data = this as TaskDescription;
    return TaskDescription(
      id: id ?? $data.id,
      displayName: displayName ?? $data.displayName,
      icon: icon ?? $data.icon,
    );
  }

  static TaskDescription fromValues(Map<String, dynamic> data) {
    return TaskDescription(
      id: data['id'],
      displayName: data['displayName'],
      icon: data['icon'],
    );
  }

  static TaskDescription fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
          TaskDescription, data.runtimeType, name);
    }
    return TaskDescription(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      displayName: $displayName.fromJson(data['displayName'],
          name: DataCodec.childName(name, 'displayName')),
      icon:
          $icon.fromJson(data['icon'], name: DataCodec.childName(name, 'icon')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as TaskDescription;
    return {
      'id': $id.toJson($$data.id),
      'displayName': $displayName.toJson($$data.displayName),
      'icon': $icon.toJson($$data.icon),
    }..removeWhere((k, v) => v == null);
  }
}
