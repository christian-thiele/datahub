// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_relation.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceRelation with DataObject<ResourceRelation> {
  const _ResourceRelation();
  static final $name = DataField<ResourceRelation, String>(
    name: 'name',
    valueOf: (p) => p.name,
  );

  static final $resourceId = DataField<ResourceRelation, String>(
    name: 'resourceId',
    valueOf: (p) => p.resourceId,
  );

  static final $filter = DataField<ResourceRelation, ResourceRelationFilter>(
    name: 'filter',
    valueOf: (p) => p.filter,
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
    final $codec = const JsonDataCodec();
    return ResourceRelation(
      name: $codec.decodeString(data['name'],
          name: DataCodec.childName(name, 'name')),
      resourceId: $codec.decodeString(data['resourceId'],
          name: DataCodec.childName(name, 'resourceId')),
      filter: ResourceRelationFilter.bean
          .fromJson(data['filter'], name: DataCodec.childName(name, 'filter')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as ResourceRelation;
    return {
      'name': $codec.encodeString($data.name),
      'resourceId': $codec.encodeString($data.resourceId),
      'filter': $data.filter.toJson(),
    }..removeWhere((k, v) => v == null);
  }
}
