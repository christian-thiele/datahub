// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_revision_info.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResourceRevisionInfo
    with DataObject<ResourceRevisionInfo> {
  const $ResourceRevisionInfo();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<ResourceRevisionInfo, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $type = DataField<ResourceRevisionInfo, ResourceRevisionType>(
    name: 'type',
    valueOf: (p) => p.type,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, ResourceRevisionType.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [
      EnumConstraint(values: ResourceRevisionType.values),
    ],
  );

  static final $timestamp = DataField<ResourceRevisionInfo, DateTime>(
    name: 'timestamp',
    valueOf: (p) => p.timestamp,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final $live = DataField<ResourceRevisionInfo, DateTime?>(
    name: 'live',
    valueOf: (p) => p.live,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $userId = DataField<ResourceRevisionInfo, String>(
    name: 'userId',
    valueOf: (p) => p.userId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $userName = DataField<ResourceRevisionInfo, String>(
    name: 'userName',
    valueOf: (p) => p.userName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<ResourceRevisionInfo> bean =
      DataBean<ResourceRevisionInfo>(
    name: 'ResourceRevisionInfo',
    fields: List<DataField<ResourceRevisionInfo, dynamic>>.unmodifiable([
      $id,
      $type,
      $timestamp,
      $live,
      $userId,
      $userName,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceRevisionInfo, dynamic>> get $$fields => bean.fields;
  ResourceRevisionInfo copyWith({
    String? id,
    ResourceRevisionType? type,
    DateTime? timestamp,
    DateTime? live,
    bool nullLive = false,
    String? userId,
    String? userName,
  }) {
    final $data = this as ResourceRevisionInfo;
    return ResourceRevisionInfo(
      id: id ?? $data.id,
      type: type ?? $data.type,
      timestamp: timestamp ?? $data.timestamp,
      live: nullLive ? null : (live ?? $data.live),
      userId: userId ?? $data.userId,
      userName: userName ?? $data.userName,
    );
  }

  static ResourceRevisionInfo fromValues(Map<String, dynamic> data) {
    return ResourceRevisionInfo(
      id: data['id'],
      type: data['type'],
      timestamp: data['timestamp'],
      live: data['live'],
      userId: data['userId'],
      userName: data['userName'],
    );
  }

  static ResourceRevisionInfo fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
          ResourceRevisionInfo, data.runtimeType, name);
    }
    return ResourceRevisionInfo(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      type:
          $type.fromJson(data['type'], name: DataCodec.childName(name, 'type')),
      timestamp: $timestamp.fromJson(data['timestamp'],
          name: DataCodec.childName(name, 'timestamp')),
      live:
          $live.fromJson(data['live'], name: DataCodec.childName(name, 'live')),
      userId: $userId.fromJson(data['userId'],
          name: DataCodec.childName(name, 'userId')),
      userName: $userName.fromJson(data['userName'],
          name: DataCodec.childName(name, 'userName')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceRevisionInfo;
    return {
      'id': $id.toJson($$data.id),
      'type': $type.toJson($$data.type),
      'timestamp': $timestamp.toJson($$data.timestamp),
      'live': $live.toJson($$data.live),
      'userId': $userId.toJson($$data.userId),
      'userName': $userName.toJson($$data.userName),
    }..removeWhere((k, v) => v == null);
  }
}
