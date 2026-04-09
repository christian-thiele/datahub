// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_revision_request.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResourceRevisionRequest
    with DataObject<ResourceRevisionRequest> {
  const $ResourceRevisionRequest();
  static const $$codec = JsonDataCodec();
  static final $fieldData =
      DataField<ResourceRevisionRequest, Map<String, dynamic>>(
        name: 'fieldData',
        valueOf: (p) => p.fieldData,
        fromJson: (value, {String? name}) => $$codec.decodeMap<dynamic>(
          value,
          $$codec.decodeDynamic,
          name: name,
        ),
        toJson: (value) =>
            $$codec.encodeMap<dynamic>(value, $$codec.encodeDynamic),
      );

  static final $from = DataField<ResourceRevisionRequest, DateTime?>(
    name: 'from',
    valueOf: (p) => p.from,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final DataBean<ResourceRevisionRequest> bean =
      DataBean<ResourceRevisionRequest>(
        name: 'ResourceRevisionRequest',
        fields: List<DataField<ResourceRevisionRequest, dynamic>>.unmodifiable([
          $fieldData,
          $from,
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
    DateTime? from,
    bool nullFrom = false,
  }) {
    final $data = this as ResourceRevisionRequest;
    return ResourceRevisionRequest(
      fieldData: fieldData ?? $data.fieldData,
      from: nullFrom ? null : (from ?? $data.from),
    );
  }

  static ResourceRevisionRequest fromValues(Map<String, dynamic> data) {
    return ResourceRevisionRequest(
      fieldData: data['fieldData'],
      from: data['from'],
    );
  }

  static ResourceRevisionRequest fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ResourceRevisionRequest,
        data.runtimeType,
        name,
      );
    }
    return ResourceRevisionRequest(
      fieldData: $fieldData.fromJson(
        data['fieldData'],
        name: DataCodec.childName(name, 'fieldData'),
      ),
      from: $from.fromJson(
        data['from'],
        name: DataCodec.childName(name, 'from'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceRevisionRequest;
    return {
      'fieldData': $fieldData.toJson($$data.fieldData),
      'from': $from.toJson($$data.from),
    }..removeWhere((k, v) => v == null);
  }
}
