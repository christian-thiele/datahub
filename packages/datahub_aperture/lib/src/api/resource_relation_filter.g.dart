// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_relation_filter.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceRelationFilter with DataObject<ResourceRelationFilter> {
  const _ResourceRelationFilter();
  static const $$codec = JsonDataCodec();
  static final $or =
      DataField<ResourceRelationFilter, List<ResourceRelationFilter>?>(
    name: 'or',
    valueOf: (p) => p.or,
    dataBean: () => ResourceRelationFilter.bean,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
        (value ?? const []),
        (v, {String? name}) => $$codec.decodeList<ResourceRelationFilter>(
            v, ResourceRelationFilter.bean.fromJson,
            name: name),
        name: name),
    toJson: (value) => $$codec.encodeNullable(
        value,
        (v) =>
            $$codec.encodeList<ResourceRelationFilter>(v, (v) => v.toJson())),
  );

  static final $and =
      DataField<ResourceRelationFilter, List<ResourceRelationFilter>?>(
    name: 'and',
    valueOf: (p) => p.and,
    dataBean: () => ResourceRelationFilter.bean,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
        (value ?? const []),
        (v, {String? name}) => $$codec.decodeList<ResourceRelationFilter>(
            v, ResourceRelationFilter.bean.fromJson,
            name: name),
        name: name),
    toJson: (value) => $$codec.encodeNullable(
        value,
        (v) =>
            $$codec.encodeList<ResourceRelationFilter>(v, (v) => v.toJson())),
  );

  static final $fieldId = DataField<ResourceRelationFilter, String?>(
    name: 'fieldId',
    valueOf: (p) => p.fieldId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $type = DataField<ResourceRelationFilter, ResourceFilterType?>(
    name: 'type',
    valueOf: (p) => p.type,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
        value,
        (v, {String? name}) =>
            $$codec.decodeEnum(v, ResourceFilterType.values, name: name),
        name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeEnum),
    constraints: [
      EnumConstraint(values: ResourceFilterType?.values),
    ],
  );

  static final $value = DataField<ResourceRelationFilter, String?>(
    name: 'value',
    valueOf: (p) => p.value,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $valueFieldId = DataField<ResourceRelationFilter, String?>(
    name: 'valueFieldId',
    valueOf: (p) => p.valueFieldId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<ResourceRelationFilter> bean =
      DataBean<ResourceRelationFilter>(
    name: 'ResourceRelationFilter',
    fields: List<DataField<ResourceRelationFilter, dynamic>>.unmodifiable([
      $or,
      $and,
      $fieldId,
      $type,
      $value,
      $valueFieldId,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceRelationFilter, dynamic>> get $$fields => bean.fields;
  ResourceRelationFilter copyWith({
    List<ResourceRelationFilter>? or,
    bool nullOr = false,
    List<ResourceRelationFilter>? and,
    bool nullAnd = false,
    String? fieldId,
    bool nullFieldId = false,
    ResourceFilterType? type,
    bool nullType = false,
    String? value,
    bool nullValue = false,
    String? valueFieldId,
    bool nullValueFieldId = false,
  }) {
    final $data = this as ResourceRelationFilter;
    return ResourceRelationFilter(
      or: nullOr ? null : (or ?? $data.or),
      and: nullAnd ? null : (and ?? $data.and),
      fieldId: nullFieldId ? null : (fieldId ?? $data.fieldId),
      type: nullType ? null : (type ?? $data.type),
      value: nullValue ? null : (value ?? $data.value),
      valueFieldId:
          nullValueFieldId ? null : (valueFieldId ?? $data.valueFieldId),
    );
  }

  static ResourceRelationFilter fromValues(Map<String, dynamic> data) {
    return ResourceRelationFilter(
      or: data['or'] ?? const [],
      and: data['and'] ?? const [],
      fieldId: data['fieldId'],
      type: data['type'],
      value: data['value'],
      valueFieldId: data['valueFieldId'],
    );
  }

  static ResourceRelationFilter fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
          ResourceRelationFilter, data.runtimeType, name);
    }
    return ResourceRelationFilter(
      or: $or.fromJson(data['or'], name: DataCodec.childName(name, 'or')),
      and: $and.fromJson(data['and'], name: DataCodec.childName(name, 'and')),
      fieldId: $fieldId.fromJson(data['fieldId'],
          name: DataCodec.childName(name, 'fieldId')),
      type:
          $type.fromJson(data['type'], name: DataCodec.childName(name, 'type')),
      value: $value.fromJson(data['value'],
          name: DataCodec.childName(name, 'value')),
      valueFieldId: $valueFieldId.fromJson(data['valueFieldId'],
          name: DataCodec.childName(name, 'valueFieldId')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceRelationFilter;
    return {
      'or': $or.toJson($$data.or),
      'and': $and.toJson($$data.and),
      'fieldId': $fieldId.toJson($$data.fieldId),
      'type': $type.toJson($$data.type),
      'value': $value.toJson($$data.value),
      'valueFieldId': $valueFieldId.toJson($$data.valueFieldId),
    }..removeWhere((k, v) => v == null);
  }
}
