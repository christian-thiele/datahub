// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_revision_request.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceRevisionRequest
    with DataObject<ResourceRevisionRequest> {
  const _ResourceRevisionRequest();
  static final $fieldData =
      DataField<ResourceRevisionRequest, Map<String, dynamic>>(
    name: 'fieldData',
    valueOf: (p) => p.fieldData,
  );

  static final $revisionLive = DataField<ResourceRevisionRequest, DateTime?>(
    name: 'revisionLive',
    valueOf: (p) => p.revisionLive,
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
    final $codec = const JsonDataCodec();
    return ResourceRevisionRequest(
      fieldData: $codec.decodeMap<dynamic>(
          data['fieldData'], $codec.decodeDynamic,
          name: DataCodec.childName(name, 'fieldData')),
      revisionLive: $codec.decodeNullable(
          data['revisionLive'], $codec.decodeDateTime,
          name: DataCodec.childName(name, 'revisionLive')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as ResourceRevisionRequest;
    return {
      'fieldData':
          $codec.encodeMap<dynamic>($data.fieldData, $codec.encodeDynamic),
      'revisionLive':
          $codec.encodeNullable($data.revisionLive, $codec.encodeDateTime),
    }..removeWhere((k, v) => v == null);
  }
}
