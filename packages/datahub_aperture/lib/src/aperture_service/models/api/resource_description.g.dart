// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_description.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceDescription with DataObject<ResourceDescription> {
  const _ResourceDescription();
  static final $id = DataField<ResourceDescription, String>(
    name: 'id',
    valueOf: (p) => p.id,
  );

  static final $name = DataField<ResourceDescription, String>(
    name: 'name',
    valueOf: (p) => p.name,
  );

  static final $namePlural = DataField<ResourceDescription, String?>(
    name: 'namePlural',
    valueOf: (p) => p.namePlural,
  );

  static final $icon = DataField<ResourceDescription, int>(
    name: 'icon',
    valueOf: (p) => p.icon,
  );

  static final $fields = DataField<ResourceDescription, List<ResourceField>>(
    name: 'fields',
    valueOf: (p) => p.fields,
  );

  static final $relations =
      DataField<ResourceDescription, List<ResourceRelation>>(
    name: 'relations',
    valueOf: (p) => p.relations,
  );

  static final $idField = DataField<ResourceDescription, String>(
    name: 'idField',
    valueOf: (p) => p.idField,
  );

  static final $displayField = DataField<ResourceDescription, String?>(
    name: 'displayField',
    valueOf: (p) => p.displayField,
  );

  static final $readOnly = DataField<ResourceDescription, bool>(
    name: 'readOnly',
    valueOf: (p) => p.readOnly,
  );

  static final DataBean<ResourceDescription> bean =
      DataBean<ResourceDescription>(
    name: 'ResourceDescription',
    fields: List<DataField<ResourceDescription, dynamic>>.unmodifiable([
      $id,
      $name,
      $namePlural,
      $icon,
      $fields,
      $relations,
      $idField,
      $displayField,
      $readOnly,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceDescription, dynamic>> get $$fields => bean.fields;
  ResourceDescription copyWith({
    String? id,
    String? name,
    String? namePlural,
    bool nullNamePlural = false,
    int? icon,
    List<ResourceField>? fields,
    List<ResourceRelation>? relations,
    String? idField,
    String? displayField,
    bool nullDisplayField = false,
    bool? readOnly,
  }) {
    final $data = this as ResourceDescription;
    return ResourceDescription(
      id: id ?? $data.id,
      name: name ?? $data.name,
      namePlural: nullNamePlural ? null : (namePlural ?? $data.namePlural),
      icon: icon ?? $data.icon,
      fields: fields ?? $data.fields,
      relations: relations ?? $data.relations,
      idField: idField ?? $data.idField,
      displayField:
          nullDisplayField ? null : (displayField ?? $data.displayField),
      readOnly: readOnly ?? $data.readOnly,
    );
  }

  static ResourceDescription fromValues(Map<String, dynamic> data) {
    return ResourceDescription(
      id: data['id'],
      name: data['name'],
      namePlural: data['namePlural'],
      icon: data['icon'],
      fields: data['fields'],
      relations: data['relations'],
      idField: data['idField'],
      displayField: data['displayField'],
      readOnly: data['readOnly'],
    );
  }

  static ResourceDescription fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
          ResourceDescription, data.runtimeType, name);
    }
    final $codec = const JsonDataCodec();
    return ResourceDescription(
      id: $codec.decodeString(data['id'],
          name: DataCodec.childName(name, 'id')),
      name: $codec.decodeString(data['name'],
          name: DataCodec.childName(name, 'name')),
      namePlural: $codec.decodeNullable(data['namePlural'], $codec.decodeString,
          name: DataCodec.childName(name, 'namePlural')),
      icon: $codec.decodeInt(data['icon'],
          name: DataCodec.childName(name, 'icon')),
      fields: $codec.decodeList<ResourceField>(
          data['fields'], ResourceField.bean.fromJson,
          name: DataCodec.childName(name, 'fields')),
      relations: $codec.decodeList<ResourceRelation>(
          data['relations'], ResourceRelation.bean.fromJson,
          name: DataCodec.childName(name, 'relations')),
      idField: $codec.decodeString(data['idField'],
          name: DataCodec.childName(name, 'idField')),
      displayField: $codec.decodeNullable(
          data['displayField'], $codec.decodeString,
          name: DataCodec.childName(name, 'displayField')),
      readOnly: $codec.decodeBool(data['readOnly'],
          name: DataCodec.childName(name, 'readOnly')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as ResourceDescription;
    return {
      'id': $codec.encodeString($data.id),
      'name': $codec.encodeString($data.name),
      'namePlural':
          $codec.encodeNullable($data.namePlural, $codec.encodeString),
      'icon': $codec.encodeInt($data.icon),
      'fields':
          $codec.encodeList<ResourceField>($data.fields, (v) => v.toJson()),
      'relations': $codec.encodeList<ResourceRelation>(
          $data.relations, (v) => v.toJson()),
      'idField': $codec.encodeString($data.idField),
      'displayField':
          $codec.encodeNullable($data.displayField, $codec.encodeString),
      'readOnly': $codec.encodeBool($data.readOnly),
    }..removeWhere((k, v) => v == null);
  }
}
