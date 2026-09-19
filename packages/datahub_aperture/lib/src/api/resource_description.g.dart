// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_description.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResourceDescription
    with DataObject<ResourceDescription> {
  const $ResourceDescription();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<ResourceDescription, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $name = DataField<ResourceDescription, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $namePlural = DataField<ResourceDescription, String?>(
    name: 'namePlural',
    valueOf: (p) => p.namePlural,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $icon = DataField<ResourceDescription, int>(
    name: 'icon',
    valueOf: (p) => p.icon,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $fields = DataField<ResourceDescription, List<ResourceField>>(
    name: 'fields',
    valueOf: (p) => p.fields,
    dataBean: () => $ResourceField.bean,
    fromJson: (value, {String? name}) => $$codec.decodeList<ResourceField>(
      value,
      $ResourceField.bean.fromJson,
      name: name,
    ),
    toJson: (value) =>
        $$codec.encodeList<ResourceField>(value, (v) => v.toJson()),
  );

  static final $relations =
      DataField<ResourceDescription, List<ResourceRelation>>(
        name: 'relations',
        valueOf: (p) => p.relations,
        dataBean: () => $ResourceRelation.bean,
        fromJson: (value, {String? name}) =>
            $$codec.decodeList<ResourceRelation>(
              value,
              $ResourceRelation.bean.fromJson,
              name: name,
            ),
        toJson: (value) =>
            $$codec.encodeList<ResourceRelation>(value, (v) => v.toJson()),
      );

  static final $idField = DataField<ResourceDescription, String>(
    name: 'idField',
    valueOf: (p) => p.idField,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $displayFields = DataField<ResourceDescription, List<String>>(
    name: 'displayFields',
    valueOf: (p) => p.displayFields,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $titleTemplate = DataField<ResourceDescription, String?>(
    name: 'titleTemplate',
    valueOf: (p) => p.titleTemplate,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $readOnly = DataField<ResourceDescription, bool>(
    name: 'readOnly',
    valueOf: (p) => p.readOnly,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $revisable = DataField<ResourceDescription, bool>(
    name: 'revisable',
    valueOf: (p) => p.revisable,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $actions = DataField<ResourceDescription, List<ResourceAction>>(
    name: 'actions',
    valueOf: (p) => p.actions,
    dataBean: () => $ResourceAction.bean,
    fromJson: (value, {String? name}) => $$codec.decodeList<ResourceAction>(
      value,
      $ResourceAction.bean.fromJson,
      name: name,
    ),
    toJson: (value) =>
        $$codec.encodeList<ResourceAction>(value, (v) => v.toJson()),
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
          $displayFields,
          $titleTemplate,
          $readOnly,
          $revisable,
          $actions,
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
    List<String>? displayFields,
    String? titleTemplate,
    bool nullTitleTemplate = false,
    bool? readOnly,
    bool? revisable,
    List<ResourceAction>? actions,
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
      displayFields: displayFields ?? $data.displayFields,
      titleTemplate: nullTitleTemplate
          ? null
          : (titleTemplate ?? $data.titleTemplate),
      readOnly: readOnly ?? $data.readOnly,
      revisable: revisable ?? $data.revisable,
      actions: actions ?? $data.actions,
    );
  }

  static ResourceDescription fromValues(Map<String, dynamic> data) {
    return ResourceDescription(
      id: data['id'],
      name: data['name'],
      namePlural: data['namePlural'],
      icon: data['icon'],
      fields: data['fields']?.cast<ResourceField>().toList(growable: false),
      relations: data['relations']?.cast<ResourceRelation>().toList(
        growable: false,
      ),
      idField: data['idField'],
      displayFields:
          data['displayFields']?.cast<String>().toList(growable: false) ??
          const [],
      titleTemplate: data['titleTemplate'],
      readOnly: data['readOnly'],
      revisable: data['revisable'],
      actions: data['actions']?.cast<ResourceAction>().toList(growable: false),
    );
  }

  static ResourceDescription fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ResourceDescription,
        data.runtimeType,
        name,
      );
    }
    return ResourceDescription(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      namePlural: $namePlural.fromJson(
        data['namePlural'],
        name: DataCodec.childName(name, 'namePlural'),
      ),
      icon: $icon.fromJson(
        data['icon'],
        name: DataCodec.childName(name, 'icon'),
      ),
      fields: $fields.fromJson(
        data['fields'],
        name: DataCodec.childName(name, 'fields'),
      ),
      relations: $relations.fromJson(
        data['relations'],
        name: DataCodec.childName(name, 'relations'),
      ),
      idField: $idField.fromJson(
        data['idField'],
        name: DataCodec.childName(name, 'idField'),
      ),
      displayFields: $displayFields.fromJson(
        data['displayFields'],
        name: DataCodec.childName(name, 'displayFields'),
      ),
      titleTemplate: $titleTemplate.fromJson(
        data['titleTemplate'],
        name: DataCodec.childName(name, 'titleTemplate'),
      ),
      readOnly: $readOnly.fromJson(
        data['readOnly'],
        name: DataCodec.childName(name, 'readOnly'),
      ),
      revisable: $revisable.fromJson(
        data['revisable'],
        name: DataCodec.childName(name, 'revisable'),
      ),
      actions: $actions.fromJson(
        data['actions'],
        name: DataCodec.childName(name, 'actions'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceDescription;
    return {
      'id': $id.toJson($$data.id),
      'name': $name.toJson($$data.name),
      'namePlural': $namePlural.toJson($$data.namePlural),
      'icon': $icon.toJson($$data.icon),
      'fields': $fields.toJson($$data.fields),
      'relations': $relations.toJson($$data.relations),
      'idField': $idField.toJson($$data.idField),
      'displayFields': $displayFields.toJson($$data.displayFields),
      'titleTemplate': $titleTemplate.toJson($$data.titleTemplate),
      'readOnly': $readOnly.toJson($$data.readOnly),
      'revisable': $revisable.toJson($$data.revisable),
      'actions': $actions.toJson($$data.actions),
    }..removeWhere((k, v) => v == null);
  }
}
