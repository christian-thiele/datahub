// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_documentation_object.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ExternalDocumentationObject
    with DataObject<ExternalDocumentationObject> {
  const $ExternalDocumentationObject();
  static const $$codec = JsonDataCodec();
  static final $description = DataField<ExternalDocumentationObject, String?>(
    name: 'description',
    valueOf: (p) => p.description,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $url = DataField<ExternalDocumentationObject, String>(
    name: 'url',
    valueOf: (p) => p.url,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<ExternalDocumentationObject> bean =
      DataBean<ExternalDocumentationObject>(
        name: 'ExternalDocumentationObject',
        fields:
            List<DataField<ExternalDocumentationObject, dynamic>>.unmodifiable([
              $description,
              $url,
            ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ExternalDocumentationObject, dynamic>> get $$fields =>
      bean.fields;
  ExternalDocumentationObject copyWith({
    String? description,
    bool nullDescription = false,
    String? url,
  }) {
    final $data = this as ExternalDocumentationObject;
    return ExternalDocumentationObject(
      description: nullDescription ? null : (description ?? $data.description),
      url: url ?? $data.url,
    );
  }

  static ExternalDocumentationObject fromValues(Map<String, dynamic> data) {
    return ExternalDocumentationObject(
      description: data['description'],
      url: data['url'],
    );
  }

  static ExternalDocumentationObject fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ExternalDocumentationObject,
        data.runtimeType,
        name,
      );
    }
    return ExternalDocumentationObject(
      description: $description.fromJson(
        data['description'],
        name: DataCodec.childName(name, 'description'),
      ),
      url: $url.fromJson(data['url'], name: DataCodec.childName(name, 'url')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ExternalDocumentationObject;
    return {
      'description': $description.toJson($$data.description),
      'url': $url.toJson($$data.url),
    }..removeWhere((k, v) => v == null);
  }
}
