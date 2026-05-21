// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_data.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResourceData with DataObject<ResourceData> {
  const $ResourceData();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<ResourceData, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $fieldData = DataField<ResourceData, Map<String, dynamic>>(
    name: 'fieldData',
    valueOf: (p) => p.fieldData,
    fromJson: (value, {String? name}) =>
        $$codec.decodeMap<dynamic>(value, $$codec.decodeDynamic, name: name),
    toJson: (value) => $$codec.encodeMap<dynamic>(value, $$codec.encodeDynamic),
  );

  static final $version = DataField<ResourceData, int?>(
    name: 'version',
    valueOf: (p) => p.version,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $revisions = DataField<ResourceData, List<ResourceRevisionInfo>>(
    name: 'revisions',
    valueOf: (p) => p.revisions,
    dataBean: () => $ResourceRevisionInfo.bean,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<ResourceRevisionInfo>(
          (value ?? const []),
          $ResourceRevisionInfo.bean.fromJson,
          name: name,
        ),
    toJson: (value) =>
        $$codec.encodeList<ResourceRevisionInfo>(value, (v) => v.toJson()),
  );

  static final DataBean<ResourceData> bean = DataBean<ResourceData>(
    name: 'ResourceData',
    fields: List<DataField<ResourceData, dynamic>>.unmodifiable([
      $id,
      $fieldData,
      $version,
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
    int? version,
    bool nullVersion = false,
    List<ResourceRevisionInfo>? revisions,
  }) {
    final $data = this as ResourceData;
    return ResourceData(
      id: id ?? $data.id,
      fieldData: fieldData ?? $data.fieldData,
      version: nullVersion ? null : (version ?? $data.version),
      revisions: revisions ?? $data.revisions,
    );
  }

  static ResourceData fromValues(Map<String, dynamic> data) {
    return ResourceData(
      id: data['id'],
      fieldData: data['fieldData'],
      version: data['version'],
      revisions:
          data['revisions']?.cast<ResourceRevisionInfo>().toList(
            growable: false,
          ) ??
          const [],
    );
  }

  static ResourceData fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ResourceData, data.runtimeType, name);
    }
    return ResourceData(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      fieldData: $fieldData.fromJson(
        data['fieldData'],
        name: DataCodec.childName(name, 'fieldData'),
      ),
      version: $version.fromJson(
        data['version'],
        name: DataCodec.childName(name, 'version'),
      ),
      revisions: $revisions.fromJson(
        data['revisions'],
        name: DataCodec.childName(name, 'revisions'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceData;
    return {
      'id': $id.toJson($$data.id),
      'fieldData': $fieldData.toJson($$data.fieldData),
      'version': $version.toJson($$data.version),
      'revisions': $revisions.toJson($$data.revisions),
    }..removeWhere((k, v) => v == null);
  }
}
