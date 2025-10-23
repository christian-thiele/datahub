// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_object.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResponseObject with DataObject<ResponseObject> {
  const $ResponseObject();
  static const $$codec = JsonDataCodec();
  static final $description = DataField<ResponseObject, String>(
    name: 'description',
    valueOf: (p) => p.description,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $schema = DataField<ResponseObject, Map<String, dynamic>>(
    name: 'schema',
    valueOf: (p) => p.schema,
    fromJson: (value, {String? name}) => $$codec.decodeMap<dynamic>(
      (value ?? const {}),
      $$codec.decodeDynamic,
      name: name,
    ),
    toJson: (value) => $$codec.encodeMap<dynamic>(value, $$codec.encodeDynamic),
  );

  static final $headers = DataField<ResponseObject, Map<String, HeaderObject>>(
    name: 'headers',
    valueOf: (p) => p.headers,
    dataBean: () => $HeaderObject.bean,
    fromJson: (value, {String? name}) => $$codec.decodeMap<HeaderObject>(
      (value ?? const {}),
      $HeaderObject.bean.fromJson,
      name: name,
    ),
    toJson: (value) =>
        $$codec.encodeMap<HeaderObject>(value, (v) => v.toJson()),
  );

  static final $examples = DataField<ResponseObject, Map<String, dynamic>>(
    name: 'examples',
    valueOf: (p) => p.examples,
    fromJson: (value, {String? name}) => $$codec.decodeMap<dynamic>(
      (value ?? const {}),
      $$codec.decodeDynamic,
      name: name,
    ),
    toJson: (value) => $$codec.encodeMap<dynamic>(value, $$codec.encodeDynamic),
  );

  static final DataBean<ResponseObject> bean = DataBean<ResponseObject>(
    name: 'ResponseObject',
    fields: List<DataField<ResponseObject, dynamic>>.unmodifiable([
      $description,
      $schema,
      $headers,
      $examples,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResponseObject, dynamic>> get $$fields => bean.fields;
  ResponseObject copyWith({
    String? description,
    Map<String, dynamic>? schema,
    Map<String, HeaderObject>? headers,
    Map<String, dynamic>? examples,
  }) {
    final $data = this as ResponseObject;
    return ResponseObject(
      description: description ?? $data.description,
      schema: schema ?? $data.schema,
      headers: headers ?? $data.headers,
      examples: examples ?? $data.examples,
    );
  }

  static ResponseObject fromValues(Map<String, dynamic> data) {
    return ResponseObject(
      description: data['description'],
      schema: data['schema'] ?? const {},
      headers: data['headers'] ?? const {},
      examples: data['examples'] ?? const {},
    );
  }

  static ResponseObject fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ResponseObject, data.runtimeType, name);
    }
    return ResponseObject(
      description: $description.fromJson(
        data['description'],
        name: DataCodec.childName(name, 'description'),
      ),
      schema: $schema.fromJson(
        data['schema'],
        name: DataCodec.childName(name, 'schema'),
      ),
      headers: $headers.fromJson(
        data['headers'],
        name: DataCodec.childName(name, 'headers'),
      ),
      examples: $examples.fromJson(
        data['examples'],
        name: DataCodec.childName(name, 'examples'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResponseObject;
    return {
      'description': $description.toJson($$data.description),
      'schema': $schema.toJson($$data.schema),
      'headers': $headers.toJson($$data.headers),
      'examples': $examples.toJson($$data.examples),
    }..removeWhere((k, v) => v == null);
  }
}
