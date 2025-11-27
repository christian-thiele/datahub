// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_field_lookup.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResourceFieldLookup
    with DataObject<ResourceFieldLookup> {
  const $ResourceFieldLookup();
  static const $$codec = JsonDataCodec();
  static final $resourceId = DataField<ResourceFieldLookup, String>(
    name: 'resourceId',
    valueOf: (p) => p.resourceId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $resourceFieldId = DataField<ResourceFieldLookup, String>(
    name: 'resourceFieldId',
    valueOf: (p) => p.resourceFieldId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $filter = DataField<ResourceFieldLookup, ResourceRelationFilter>(
    name: 'filter',
    valueOf: (p) => p.filter,
    dataBean: () => $ResourceRelationFilter.bean,
    fromJson: (value, {String? name}) =>
        $ResourceRelationFilter.bean.fromJson(value, name: name),
    toJson: (value) => value.toJson(),
  );

  static final DataBean<ResourceFieldLookup> bean =
      DataBean<ResourceFieldLookup>(
        name: 'ResourceFieldLookup',
        fields: List<DataField<ResourceFieldLookup, dynamic>>.unmodifiable([
          $resourceId,
          $resourceFieldId,
          $filter,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceFieldLookup, dynamic>> get $$fields => bean.fields;
  ResourceFieldLookup copyWith({
    String? resourceId,
    String? resourceFieldId,
    ResourceRelationFilter? filter,
  }) {
    final $data = this as ResourceFieldLookup;
    return ResourceFieldLookup(
      resourceId: resourceId ?? $data.resourceId,
      resourceFieldId: resourceFieldId ?? $data.resourceFieldId,
      filter: filter ?? $data.filter,
    );
  }

  static ResourceFieldLookup fromValues(Map<String, dynamic> data) {
    return ResourceFieldLookup(
      resourceId: data['resourceId'],
      resourceFieldId: data['resourceFieldId'],
      filter: data['filter'],
    );
  }

  static ResourceFieldLookup fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ResourceFieldLookup,
        data.runtimeType,
        name,
      );
    }
    return ResourceFieldLookup(
      resourceId: $resourceId.fromJson(
        data['resourceId'],
        name: DataCodec.childName(name, 'resourceId'),
      ),
      resourceFieldId: $resourceFieldId.fromJson(
        data['resourceFieldId'],
        name: DataCodec.childName(name, 'resourceFieldId'),
      ),
      filter: $filter.fromJson(
        data['filter'],
        name: DataCodec.childName(name, 'filter'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceFieldLookup;
    return {
      'resourceId': $resourceId.toJson($$data.resourceId),
      'resourceFieldId': $resourceFieldId.toJson($$data.resourceFieldId),
      'filter': $filter.toJson($$data.filter),
    }..removeWhere((k, v) => v == null);
  }
}
