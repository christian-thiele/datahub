// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_revision_info.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceRevisionInfo with DataObject<ResourceRevisionInfo> {
  const _ResourceRevisionInfo();
  static final $id = DataField<ResourceRevisionInfo, String>(
    name: 'id',
    valueOf: (p) => p.id,
  );

  static final $type = DataField<ResourceRevisionInfo, ResourceRevisionType>(
    name: 'type',
    valueOf: (p) => p.type,
  );

  static final $timestamp = DataField<ResourceRevisionInfo, DateTime>(
    name: 'timestamp',
    valueOf: (p) => p.timestamp,
  );

  static final $live = DataField<ResourceRevisionInfo, DateTime?>(
    name: 'live',
    valueOf: (p) => p.live,
  );

  static final $userId = DataField<ResourceRevisionInfo, String>(
    name: 'userId',
    valueOf: (p) => p.userId,
  );

  static final $userName = DataField<ResourceRevisionInfo, String>(
    name: 'userName',
    valueOf: (p) => p.userName,
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
    final $codec = const JsonDataCodec();
    return ResourceRevisionInfo(
      id: $codec.decodeString(data['id'],
          name: DataCodec.childName(name, 'id')),
      type: $codec.decodeEnum(data['type'], ResourceRevisionType.values,
          name: name),
      timestamp: $codec.decodeDateTime(data['timestamp'],
          name: DataCodec.childName(name, 'timestamp')),
      live: $codec.decodeNullable(data['live'], $codec.decodeDateTime,
          name: DataCodec.childName(name, 'live')),
      userId: $codec.decodeString(data['userId'],
          name: DataCodec.childName(name, 'userId')),
      userName: $codec.decodeString(data['userName'],
          name: DataCodec.childName(name, 'userName')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as ResourceRevisionInfo;
    return {
      'id': $codec.encodeString($data.id),
      'type': $codec.encodeEnum($data.type),
      'timestamp': $codec.encodeDateTime($data.timestamp),
      'live': $codec.encodeNullable($data.live, $codec.encodeDateTime),
      'userId': $codec.encodeString($data.userId),
      'userName': $codec.encodeString($data.userName),
    }..removeWhere((k, v) => v == null);
  }
}
