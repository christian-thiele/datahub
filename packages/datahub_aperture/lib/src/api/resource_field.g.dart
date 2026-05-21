// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_field.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResourceField with DataObject<ResourceField> {
  const $ResourceField();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<ResourceField, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $name = DataField<ResourceField, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $type = DataField<ResourceField, ResourceFieldType>(
    name: 'type',
    valueOf: (p) => p.type,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, ResourceFieldType.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: ResourceFieldType.values)],
  );

  static final $nullable = DataField<ResourceField, bool>(
    name: 'nullable',
    valueOf: (p) => p.nullable,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $description = DataField<ResourceField, String?>(
    name: 'description',
    valueOf: (p) => p.description,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $readOnly = DataField<ResourceField, bool>(
    name: 'readOnly',
    valueOf: (p) => p.readOnly,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $length = DataField<ResourceField, int?>(
    name: 'length',
    valueOf: (p) => p.length,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $validation = DataField<ResourceField, String?>(
    name: 'validation',
    valueOf: (p) => p.validation,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $objectDescription =
      DataField<ResourceField, List<ResourceField>?>(
        name: 'objectDescription',
        valueOf: (p) => p.objectDescription,
        dataBean: () => $ResourceField.bean,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) => $$codec.decodeList<ResourceField>(
            v,
            $ResourceField.bean.fromJson,
            name: name,
          ),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<ResourceField>(v, (v) => v.toJson()),
        ),
      );

  static final $enumValues = DataField<ResourceField, List<String>?>(
    name: 'enumValues',
    valueOf: (p) => p.enumValues,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      (v, {String? name}) =>
          $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(
      value,
      (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
    ),
  );

  static final $lookup = DataField<ResourceField, ResourceFieldLookup?>(
    name: 'lookup',
    valueOf: (p) => p.lookup,
    dataBean: () => $ResourceFieldLookup.bean,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      $ResourceFieldLookup.bean.fromJson,
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
  );

  static final DataBean<ResourceField> bean = DataBean<ResourceField>(
    name: 'ResourceField',
    fields: List<DataField<ResourceField, dynamic>>.unmodifiable([
      $id,
      $name,
      $type,
      $nullable,
      $description,
      $readOnly,
      $length,
      $validation,
      $objectDescription,
      $enumValues,
      $lookup,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceField, dynamic>> get $$fields => bean.fields;
  ResourceField copyWith({
    String? id,
    String? name,
    ResourceFieldType? type,
    bool? nullable,
    String? description,
    bool nullDescription = false,
    bool? readOnly,
    int? length,
    bool nullLength = false,
    String? validation,
    bool nullValidation = false,
    List<ResourceField>? objectDescription,
    bool nullObjectDescription = false,
    List<String>? enumValues,
    bool nullEnumValues = false,
    ResourceFieldLookup? lookup,
    bool nullLookup = false,
  }) {
    final $data = this as ResourceField;
    return ResourceField(
      id: id ?? $data.id,
      name: name ?? $data.name,
      type: type ?? $data.type,
      nullable: nullable ?? $data.nullable,
      description: nullDescription ? null : (description ?? $data.description),
      readOnly: readOnly ?? $data.readOnly,
      length: nullLength ? null : (length ?? $data.length),
      validation: nullValidation ? null : (validation ?? $data.validation),
      objectDescription: nullObjectDescription
          ? null
          : (objectDescription ?? $data.objectDescription),
      enumValues: nullEnumValues ? null : (enumValues ?? $data.enumValues),
      lookup: nullLookup ? null : (lookup ?? $data.lookup),
    );
  }

  static ResourceField fromValues(Map<String, dynamic> data) {
    return ResourceField(
      id: data['id'],
      name: data['name'],
      type: data['type'],
      nullable: data['nullable'] ?? false,
      description: data['description'],
      readOnly: data['readOnly'] ?? false,
      length: data['length'],
      validation: data['validation'],
      objectDescription: data['objectDescription']
          ?.cast<ResourceField>()
          .toList(growable: false),
      enumValues: data['enumValues']?.cast<String>().toList(growable: false),
      lookup: data['lookup'],
    );
  }

  static ResourceField fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ResourceField, data.runtimeType, name);
    }
    return ResourceField(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      type: $type.fromJson(
        data['type'],
        name: DataCodec.childName(name, 'type'),
      ),
      nullable: $nullable.fromJson(
        data['nullable'],
        name: DataCodec.childName(name, 'nullable'),
      ),
      description: $description.fromJson(
        data['description'],
        name: DataCodec.childName(name, 'description'),
      ),
      readOnly: $readOnly.fromJson(
        data['readOnly'],
        name: DataCodec.childName(name, 'readOnly'),
      ),
      length: $length.fromJson(
        data['length'],
        name: DataCodec.childName(name, 'length'),
      ),
      validation: $validation.fromJson(
        data['validation'],
        name: DataCodec.childName(name, 'validation'),
      ),
      objectDescription: $objectDescription.fromJson(
        data['objectDescription'],
        name: DataCodec.childName(name, 'objectDescription'),
      ),
      enumValues: $enumValues.fromJson(
        data['enumValues'],
        name: DataCodec.childName(name, 'enumValues'),
      ),
      lookup: $lookup.fromJson(
        data['lookup'],
        name: DataCodec.childName(name, 'lookup'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceField;
    return {
      'id': $id.toJson($$data.id),
      'name': $name.toJson($$data.name),
      'type': $type.toJson($$data.type),
      'nullable': $nullable.toJson($$data.nullable),
      'description': $description.toJson($$data.description),
      'readOnly': $readOnly.toJson($$data.readOnly),
      'length': $length.toJson($$data.length),
      'validation': $validation.toJson($$data.validation),
      'objectDescription': $objectDescription.toJson($$data.objectDescription),
      'enumValues': $enumValues.toJson($$data.enumValues),
      'lookup': $lookup.toJson($$data.lookup),
    }..removeWhere((k, v) => v == null);
  }
}
