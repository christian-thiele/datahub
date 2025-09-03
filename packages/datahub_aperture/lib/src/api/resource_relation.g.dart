// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_relation.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceRelation with DataObject<ResourceRelation> {
  const _ResourceRelation();
  static const $$codec = JsonDataCodec();
  static final $name = DataField<ResourceRelation, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $resourceId = DataField<ResourceRelation, String>(
    name: 'resourceId',
    valueOf: (p) => p.resourceId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $filter = DataField<ResourceRelation, ResourceRelationFilter>(
    name: 'filter',
    valueOf: (p) => p.filter,
    dataBean: () => ResourceRelationFilter.bean,
    fromJson: (value, {String? name}) =>
        ResourceRelationFilter.bean.fromJson(value, name: name),
    toJson: (value) => value.toJson(),
  );

  static final DataBean<ResourceRelation> bean = DataBean<ResourceRelation>(
    name: 'ResourceRelation',
    fields: List<DataField<ResourceRelation, dynamic>>.unmodifiable([
      $name,
      $resourceId,
      $filter,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceRelation, dynamic>> get $$fields => bean.fields;
  ResourceRelation copyWith({
    String? name,
    String? resourceId,
    ResourceRelationFilter? filter,
  }) {
    final $data = this as ResourceRelation;
    return ResourceRelation(
      name: name ?? $data.name,
      resourceId: resourceId ?? $data.resourceId,
      filter: filter ?? $data.filter,
    );
  }

  static ResourceRelation fromValues(Map<String, dynamic> data) {
    return ResourceRelation(
      name: data['name'],
      resourceId: data['resourceId'],
      filter: data['filter'],
    );
  }

  static ResourceRelation fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
          ResourceRelation, data.runtimeType, name);
    }
    return ResourceRelation(
      name:
          $name.fromJson(data['name'], name: DataCodec.childName(name, 'name')),
      resourceId: $resourceId.fromJson(data['resourceId'],
          name: DataCodec.childName(name, 'resourceId')),
      filter: $filter.fromJson(data['filter'],
          name: DataCodec.childName(name, 'filter')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceRelation;
    return {
      'name': $name.toJson($$data.name),
      'resourceId': $resourceId.toJson($$data.resourceId),
      'filter': $filter.toJson($$data.filter),
    }..removeWhere((k, v) => v == null);
  }
}
