// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_field.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceField with DataObject<ResourceField> {
  const _ResourceField();
  static final $id = DataField<ResourceField, String>(
    name: 'id',
    valueOf: (p) => p.id,
  );

  static final $name = DataField<ResourceField, String>(
    name: 'name',
    valueOf: (p) => p.name,
  );

  static final $type = DataField<ResourceField, ResourceFieldType>(
    name: 'type',
    valueOf: (p) => p.type,
  );

  static final $nullable = DataField<ResourceField, bool>(
    name: 'nullable',
    valueOf: (p) => p.nullable,
  );

  static final $description = DataField<ResourceField, String?>(
    name: 'description',
    valueOf: (p) => p.description,
  );

  static final $readOnly = DataField<ResourceField, bool>(
    name: 'readOnly',
    valueOf: (p) => p.readOnly,
  );

  static final $length = DataField<ResourceField, int?>(
    name: 'length',
    valueOf: (p) => p.length,
  );

  static final $validation = DataField<ResourceField, String?>(
    name: 'validation',
    valueOf: (p) => p.validation,
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
    );
  }

  static ResourceField fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ResourceField, data.runtimeType, name);
    }
    final $codec = const JsonDataCodec();
    return ResourceField(
      id: $codec.decodeString(data['id'],
          name: DataCodec.childName(name, 'id')),
      name: $codec.decodeString(data['name'],
          name: DataCodec.childName(name, 'name')),
      type:
          $codec.decodeEnum(data['type'], ResourceFieldType.values, name: name),
      nullable: $codec.decodeBool((data['nullable'] ?? false),
          name: DataCodec.childName(name, 'nullable')),
      description: $codec.decodeNullable(
          data['description'], $codec.decodeString,
          name: DataCodec.childName(name, 'description')),
      readOnly: $codec.decodeBool((data['readOnly'] ?? false),
          name: DataCodec.childName(name, 'readOnly')),
      length: $codec.decodeNullable(data['length'], $codec.decodeInt,
          name: DataCodec.childName(name, 'length')),
      validation: $codec.decodeNullable(data['validation'], $codec.decodeString,
          name: DataCodec.childName(name, 'validation')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as ResourceField;
    return {
      'id': $codec.encodeString($data.id),
      'name': $codec.encodeString($data.name),
      'type': $codec.encodeEnum($data.type),
      'nullable': $codec.encodeBool($data.nullable),
      'description':
          $codec.encodeNullable($data.description, $codec.encodeString),
      'readOnly': $codec.encodeBool($data.readOnly),
      'length': $codec.encodeNullable($data.length, $codec.encodeInt),
      'validation':
          $codec.encodeNullable($data.validation, $codec.encodeString),
    }..removeWhere((k, v) => v == null);
  }
}
