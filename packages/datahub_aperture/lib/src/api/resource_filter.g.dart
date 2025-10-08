// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_filter.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResourceFilter with DataObject<ResourceFilter> {
  const $ResourceFilter();
  static const $$codec = JsonDataCodec();
  static final $or = DataField<ResourceFilter, List<ResourceFilter>?>(
    name: 'or',
    valueOf: (p) => p.or,
    dataBean: () => $ResourceFilter.bean,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
        (value ?? const []),
        (v, {String? name}) => $$codec.decodeList<ResourceFilter>(
            v, $ResourceFilter.bean.fromJson,
            name: name),
        name: name),
    toJson: (value) => $$codec.encodeNullable(
        value, (v) => $$codec.encodeList<ResourceFilter>(v, (v) => v.toJson())),
  );

  static final $and = DataField<ResourceFilter, List<ResourceFilter>?>(
    name: 'and',
    valueOf: (p) => p.and,
    dataBean: () => $ResourceFilter.bean,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
        (value ?? const []),
        (v, {String? name}) => $$codec.decodeList<ResourceFilter>(
            v, $ResourceFilter.bean.fromJson,
            name: name),
        name: name),
    toJson: (value) => $$codec.encodeNullable(
        value, (v) => $$codec.encodeList<ResourceFilter>(v, (v) => v.toJson())),
  );

  static final $fieldId = DataField<ResourceFilter, String?>(
    name: 'fieldId',
    valueOf: (p) => p.fieldId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $type = DataField<ResourceFilter, ResourceFilterType?>(
    name: 'type',
    valueOf: (p) => p.type,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
        value,
        (v, {String? name}) =>
            $$codec.decodeEnum(v, ResourceFilterType.values, name: name),
        name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeEnum),
    constraints: [
      EnumConstraint(values: ResourceFilterType.values),
    ],
  );

  static final $value = DataField<ResourceFilter, String?>(
    name: 'value',
    valueOf: (p) => p.value,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
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
    return ResourceFilter(
      or: $or.fromJson(data['or'], name: DataCodec.childName(name, 'or')),
      and: $and.fromJson(data['and'], name: DataCodec.childName(name, 'and')),
      fieldId: $fieldId.fromJson(data['fieldId'],
          name: DataCodec.childName(name, 'fieldId')),
      type:
          $type.fromJson(data['type'], name: DataCodec.childName(name, 'type')),
      value: $value.fromJson(data['value'],
          name: DataCodec.childName(name, 'value')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceFilter;
    return {
      'or': $or.toJson($$data.or),
      'and': $and.toJson($$data.and),
      'fieldId': $fieldId.toJson($$data.fieldId),
      'type': $type.toJson($$data.type),
      'value': $value.toJson($$data.value),
    }..removeWhere((k, v) => v == null);
  }
}
