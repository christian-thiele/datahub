// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_object.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $TagObject with DataObject<TagObject> {
  const $TagObject();
  static const $$codec = JsonDataCodec();
  static final $name = DataField<TagObject, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $description = DataField<TagObject, String?>(
    name: 'description',
    valueOf: (p) => p.description,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $externalDocs =
      DataField<TagObject, ExternalDocumentationObject?>(
        name: 'externalDocs',
        valueOf: (p) => p.externalDocs,
        dataBean: () => $ExternalDocumentationObject.bean,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          $ExternalDocumentationObject.bean.fromJson,
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
      );

  static final DataBean<TagObject> bean = DataBean<TagObject>(
    name: 'TagObject',
    fields: List<DataField<TagObject, dynamic>>.unmodifiable([
      $name,
      $description,
      $externalDocs,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<TagObject, dynamic>> get $$fields => bean.fields;
  TagObject copyWith({
    String? name,
    String? description,
    bool nullDescription = false,
    ExternalDocumentationObject? externalDocs,
    bool nullExternalDocs = false,
  }) {
    final $data = this as TagObject;
    return TagObject(
      name: name ?? $data.name,
      description: nullDescription ? null : (description ?? $data.description),
      externalDocs: nullExternalDocs
          ? null
          : (externalDocs ?? $data.externalDocs),
    );
  }

  static TagObject fromValues(Map<String, dynamic> data) {
    return TagObject(
      name: data['name'],
      description: data['description'],
      externalDocs: data['externalDocs'],
    );
  }

  static TagObject fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(TagObject, data.runtimeType, name);
    }
    return TagObject(
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      description: $description.fromJson(
        data['description'],
        name: DataCodec.childName(name, 'description'),
      ),
      externalDocs: $externalDocs.fromJson(
        data['externalDocs'],
        name: DataCodec.childName(name, 'externalDocs'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as TagObject;
    return {
      'name': $name.toJson($$data.name),
      'description': $description.toJson($$data.description),
      'externalDocs': $externalDocs.toJson($$data.externalDocs),
    }..removeWhere((k, v) => v == null);
  }
}
