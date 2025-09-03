// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_revision_request.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceRevisionRequest
    with DataObject<ResourceRevisionRequest> {
  const _ResourceRevisionRequest();
  static const $$codec = JsonDataCodec();
  static final $fieldData =
      DataField<ResourceRevisionRequest, Map<String, dynamic>>(
    name: 'fieldData',
    valueOf: (p) => p.fieldData,
    fromJson: (value, {String? name}) =>
        $$codec.decodeMap<dynamic>(value, $$codec.decodeDynamic, name: name),
    toJson: (value) => $$codec.encodeMap<dynamic>(value, $$codec.encodeDynamic),
  );

  static final $revisionLive = DataField<ResourceRevisionRequest, DateTime?>(
    name: 'revisionLive',
    valueOf: (p) => p.revisionLive,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final DataBean<ResourceRevisionRequest> bean =
      DataBean<ResourceRevisionRequest>(
    name: 'ResourceRevisionRequest',
    fields: List<DataField<ResourceRevisionRequest, dynamic>>.unmodifiable([
      $fieldData,
      $revisionLive,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceRevisionRequest, dynamic>> get $$fields => bean.fields;
  ResourceRevisionRequest copyWith({
    Map<String, dynamic>? fieldData,
    DateTime? revisionLive,
    bool nullRevisionLive = false,
  }) {
    final $data = this as ResourceRevisionRequest;
    return ResourceRevisionRequest(
      fieldData: fieldData ?? $data.fieldData,
      revisionLive:
          nullRevisionLive ? null : (revisionLive ?? $data.revisionLive),
    );
  }

  static ResourceRevisionRequest fromValues(Map<String, dynamic> data) {
    return ResourceRevisionRequest(
      fieldData: data['fieldData'],
      revisionLive: data['revisionLive'],
    );
  }

  static ResourceRevisionRequest fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
          ResourceRevisionRequest, data.runtimeType, name);
    }
    return ResourceRevisionRequest(
      fieldData: $fieldData.fromJson(data['fieldData'],
          name: DataCodec.childName(name, 'fieldData')),
      revisionLive: $revisionLive.fromJson(data['revisionLive'],
          name: DataCodec.childName(name, 'revisionLive')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceRevisionRequest;
    return {
      'fieldData': $fieldData.toJson($$data.fieldData),
      'revisionLive': $revisionLive.toJson($$data.revisionLive),
    }..removeWhere((k, v) => v == null);
  }
}
