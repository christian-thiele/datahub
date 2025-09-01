// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_data.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceData with DataObject<ResourceData> {
  const _ResourceData();
  static final $id = DataField<ResourceData, String>(
    name: 'id',
    valueOf: (p) => p.id,
  );

  static final $fieldData = DataField<ResourceData, Map<String, dynamic>>(
    name: 'fieldData',
    valueOf: (p) => p.fieldData,
  );

  static final $revisionId = DataField<ResourceData, String?>(
    name: 'revisionId',
    valueOf: (p) => p.revisionId,
  );

  static final $revisions = DataField<ResourceData, List<ResourceRevisionInfo>>(
    name: 'revisions',
    valueOf: (p) => p.revisions,
  );

  static final DataBean<ResourceData> bean = DataBean<ResourceData>(
    name: 'ResourceData',
    fields: List<DataField<ResourceData, dynamic>>.unmodifiable([
      $id,
      $fieldData,
      $revisionId,
      $revisions,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceData, dynamic>> get $$fields => bean.fields;
  ResourceData copyWith({
    String? id,
    Map<String, dynamic>? fieldData,
    String? revisionId,
    bool nullRevisionId = false,
    List<ResourceRevisionInfo>? revisions,
  }) {
    final $data = this as ResourceData;
    return ResourceData(
      id: id ?? $data.id,
      fieldData: fieldData ?? $data.fieldData,
      revisionId: nullRevisionId ? null : (revisionId ?? $data.revisionId),
      revisions: revisions ?? $data.revisions,
    );
  }

  static ResourceData fromValues(Map<String, dynamic> data) {
    return ResourceData(
      id: data['id'],
      fieldData: data['fieldData'],
      revisionId: data['revisionId'],
      revisions: data['revisions'] ?? const [],
    );
  }

  static ResourceData fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ResourceData, data.runtimeType, name);
    }
    final $codec = const JsonDataCodec();
    return ResourceData(
      id: $codec.decodeString(data['id'],
          name: DataCodec.childName(name, 'id')),
      fieldData: $codec.decodeMap<dynamic>(
          data['fieldData'], $codec.decodeDynamic,
          name: DataCodec.childName(name, 'fieldData')),
      revisionId: $codec.decodeNullable(data['revisionId'], $codec.decodeString,
          name: DataCodec.childName(name, 'revisionId')),
      revisions: $codec.decodeList<ResourceRevisionInfo>(
          (data['revisions'] ?? const []), ResourceRevisionInfo.bean.fromJson,
          name: DataCodec.childName(name, 'revisions')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as ResourceData;
    return {
      'id': $codec.encodeString($data.id),
      'fieldData':
          $codec.encodeMap<dynamic>($data.fieldData, $codec.encodeDynamic),
      'revisionId':
          $codec.encodeNullable($data.revisionId, $codec.encodeString),
      'revisions': $codec.encodeList<ResourceRevisionInfo>(
          $data.revisions, (v) => v.toJson()),
    }..removeWhere((k, v) => v == null);
  }
}
