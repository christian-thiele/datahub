// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_relation_filter.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceRelationFilter with DataObject<ResourceRelationFilter> {
  const _ResourceRelationFilter();
  static final $or =
      DataField<ResourceRelationFilter, List<ResourceRelationFilter>?>(
    name: 'or',
    valueOf: (p) => p.or,
  );

  static final $and =
      DataField<ResourceRelationFilter, List<ResourceRelationFilter>?>(
    name: 'and',
    valueOf: (p) => p.and,
  );

  static final $fieldId = DataField<ResourceRelationFilter, String?>(
    name: 'fieldId',
    valueOf: (p) => p.fieldId,
  );

  static final $type = DataField<ResourceRelationFilter, ResourceFilterType?>(
    name: 'type',
    valueOf: (p) => p.type,
  );

  static final $value = DataField<ResourceRelationFilter, String?>(
    name: 'value',
    valueOf: (p) => p.value,
  );

  static final $valueFieldId = DataField<ResourceRelationFilter, String?>(
    name: 'valueFieldId',
    valueOf: (p) => p.valueFieldId,
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
    final $codec = const JsonDataCodec();
    return ResourceRelationFilter(
      or: $codec.decodeNullable(
          (data['or'] ?? const []),
          (v, {String? name}) => $codec.decodeList<ResourceRelationFilter>(
              v, ResourceRelationFilter.bean.fromJson,
              name: name),
          name: DataCodec.childName(name, 'or')),
      and: $codec.decodeNullable(
          (data['and'] ?? const []),
          (v, {String? name}) => $codec.decodeList<ResourceRelationFilter>(
              v, ResourceRelationFilter.bean.fromJson,
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
      valueFieldId: $codec.decodeNullable(
          data['valueFieldId'], $codec.decodeString,
          name: DataCodec.childName(name, 'valueFieldId')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as ResourceRelationFilter;
    return {
      'or': $codec.encodeNullable(
          $data.or,
          (v) =>
              $codec.encodeList<ResourceRelationFilter>(v, (v) => v.toJson())),
      'and': $codec.encodeNullable(
          $data.and,
          (v) =>
              $codec.encodeList<ResourceRelationFilter>(v, (v) => v.toJson())),
      'fieldId': $codec.encodeNullable($data.fieldId, $codec.encodeString),
      'type': $codec.encodeNullable($data.type, $codec.encodeEnum),
      'value': $codec.encodeNullable($data.value, $codec.encodeString),
      'valueFieldId':
          $codec.encodeNullable($data.valueFieldId, $codec.encodeString),
    }..removeWhere((k, v) => v == null);
  }
}
