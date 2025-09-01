// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_filter.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceFilter with DataObject<ResourceFilter> {
  const _ResourceFilter();
  static final $or = DataField<ResourceFilter, List<ResourceFilter>?>(
    name: 'or',
    valueOf: (p) => p.or,
  );

  static final $and = DataField<ResourceFilter, List<ResourceFilter>?>(
    name: 'and',
    valueOf: (p) => p.and,
  );

  static final $fieldId = DataField<ResourceFilter, String?>(
    name: 'fieldId',
    valueOf: (p) => p.fieldId,
  );

  static final $type = DataField<ResourceFilter, ResourceFilterType?>(
    name: 'type',
    valueOf: (p) => p.type,
  );

  static final $value = DataField<ResourceFilter, String?>(
    name: 'value',
    valueOf: (p) => p.value,
  );

  static final DataBean<ResourceFilter> bean = DataBean<ResourceFilter>(
    name: 'ResourceFilter',
    fields: List<DataField<ResourceFilter, dynamic>>.unmodifiable([
      $or,
      $and,
      $fieldId,
      $type,
      $value,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceFilter, dynamic>> get $$fields => bean.fields;
  ResourceFilter copyWith({
    List<ResourceFilter>? or,
    bool nullOr = false,
    List<ResourceFilter>? and,
    bool nullAnd = false,
    String? fieldId,
    bool nullFieldId = false,
    ResourceFilterType? type,
    bool nullType = false,
    String? value,
    bool nullValue = false,
  }) {
    final $data = this as ResourceFilter;
    return ResourceFilter(
      or: nullOr ? null : (or ?? $data.or),
      and: nullAnd ? null : (and ?? $data.and),
      fieldId: nullFieldId ? null : (fieldId ?? $data.fieldId),
      type: nullType ? null : (type ?? $data.type),
      value: nullValue ? null : (value ?? $data.value),
    );
  }

  static ResourceFilter fromValues(Map<String, dynamic> data) {
    return ResourceFilter(
      or: data['or'] ?? const [],
      and: data['and'] ?? const [],
      fieldId: data['fieldId'],
      type: data['type'],
      value: data['value'],
    );
  }

  static ResourceFilter fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ResourceFilter, data.runtimeType, name);
    }
    final $codec = const JsonDataCodec();
    return ResourceFilter(
      or: $codec.decodeNullable(
          (data['or'] ?? const []),
          (v, {String? name}) => $codec.decodeList<ResourceFilter>(
              v, ResourceFilter.bean.fromJson,
              name: name),
          name: DataCodec.childName(name, 'or')),
      and: $codec.decodeNullable(
          (data['and'] ?? const []),
          (v, {String? name}) => $codec.decodeList<ResourceFilter>(
              v, ResourceFilter.bean.fromJson,
              name: name),
          name: DataCodec.childName(name, 'and')),
      fieldId: $codec.decodeNullable(data['fieldId'], $codec.decodeString,
          name: DataCodec.childName(name, 'fieldId')),
      type: $codec.decodeNullable(
          data['type'],
          (v, {String? name}) =>
              $codec.decodeEnum(v, ResourceFilterType.values, name: name),
          name: DataCodec.childName(name, 'type')),
      value: $codec.decodeNullable(data['value'], $codec.decodeString,
          name: DataCodec.childName(name, 'value')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as ResourceFilter;
    return {
      'or': $codec.encodeNullable($data.or,
          (v) => $codec.encodeList<ResourceFilter>(v, (v) => v.toJson())),
      'and': $codec.encodeNullable($data.and,
          (v) => $codec.encodeList<ResourceFilter>(v, (v) => v.toJson())),
      'fieldId': $codec.encodeNullable($data.fieldId, $codec.encodeString),
      'type': $codec.encodeNullable($data.type, $codec.encodeEnum),
      'value': $codec.encodeNullable($data.value, $codec.encodeString),
    }..removeWhere((k, v) => v == null);
  }
}
