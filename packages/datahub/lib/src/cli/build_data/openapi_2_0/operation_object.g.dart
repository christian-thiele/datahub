// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_object.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $OperationObject with DataObject<OperationObject> {
  const $OperationObject();
  static const $$codec = JsonDataCodec();
  static final $tags = DataField<OperationObject, List<String>>(
    name: 'tags',
    valueOf: (p) => p.tags,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $summary = DataField<OperationObject, String?>(
    name: 'summary',
    valueOf: (p) => p.summary,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $description = DataField<OperationObject, String?>(
    name: 'description',
    valueOf: (p) => p.description,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $externalDocs =
      DataField<OperationObject, ExternalDocumentationObject?>(
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

  static final $operationId = DataField<OperationObject, String?>(
    name: 'operationId',
    valueOf: (p) => p.operationId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $consumes = DataField<OperationObject, List<String>>(
    name: 'consumes',
    valueOf: (p) => p.consumes,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $produces = DataField<OperationObject, List<String>>(
    name: 'produces',
    valueOf: (p) => p.produces,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $responses =
      DataField<OperationObject, Map<String, ResponseObject>>(
        name: 'responses',
        valueOf: (p) => p.responses,
        dataBean: () => $ResponseObject.bean,
        fromJson: (value, {String? name}) => $$codec.decodeMap<ResponseObject>(
          value,
          $ResponseObject.bean.fromJson,
          name: name,
        ),
        toJson: (value) =>
            $$codec.encodeMap<ResponseObject>(value, (v) => v.toJson()),
      );

  static final $schemes = DataField<OperationObject, List<String>>(
    name: 'schemes',
    valueOf: (p) => p.schemes,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $deprecated = DataField<OperationObject, bool>(
    name: 'deprecated',
    valueOf: (p) => p.deprecated,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $security = DataField<OperationObject, List<dynamic>>(
    name: 'security',
    valueOf: (p) => p.security,
    fromJson: (value, {String? name}) => $$codec.decodeList<dynamic>(
      (value ?? const []),
      $$codec.decodeDynamic,
      name: name,
    ),
    toJson: (value) =>
        $$codec.encodeList<dynamic>(value, $$codec.encodeDynamic),
  );

  static final DataBean<OperationObject> bean = DataBean<OperationObject>(
    name: 'OperationObject',
    fields: List<DataField<OperationObject, dynamic>>.unmodifiable([
      $tags,
      $summary,
      $description,
      $externalDocs,
      $operationId,
      $consumes,
      $produces,
      $responses,
      $schemes,
      $deprecated,
      $security,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<OperationObject, dynamic>> get $$fields => bean.fields;
  OperationObject copyWith({
    List<String>? tags,
    String? summary,
    bool nullSummary = false,
    String? description,
    bool nullDescription = false,
    ExternalDocumentationObject? externalDocs,
    bool nullExternalDocs = false,
    String? operationId,
    bool nullOperationId = false,
    List<String>? consumes,
    List<String>? produces,
    Map<String, ResponseObject>? responses,
    List<String>? schemes,
    bool? deprecated,
    List<dynamic>? security,
  }) {
    final $data = this as OperationObject;
    return OperationObject(
      tags: tags ?? $data.tags,
      summary: nullSummary ? null : (summary ?? $data.summary),
      description: nullDescription ? null : (description ?? $data.description),
      externalDocs: nullExternalDocs
          ? null
          : (externalDocs ?? $data.externalDocs),
      operationId: nullOperationId ? null : (operationId ?? $data.operationId),
      consumes: consumes ?? $data.consumes,
      produces: produces ?? $data.produces,
      responses: responses ?? $data.responses,
      schemes: schemes ?? $data.schemes,
      deprecated: deprecated ?? $data.deprecated,
      security: security ?? $data.security,
    );
  }

  static OperationObject fromValues(Map<String, dynamic> data) {
    return OperationObject(
      tags: data['tags'] ?? const [],
      summary: data['summary'],
      description: data['description'],
      externalDocs: data['externalDocs'],
      operationId: data['operationId'],
      consumes: data['consumes'] ?? const [],
      produces: data['produces'] ?? const [],
      responses: data['responses'],
      schemes: data['schemes'] ?? const [],
      deprecated: data['deprecated'] ?? false,
      security: data['security'] ?? const [],
    );
  }

  static OperationObject fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        OperationObject,
        data.runtimeType,
        name,
      );
    }
    return OperationObject(
      tags: $tags.fromJson(
        data['tags'],
        name: DataCodec.childName(name, 'tags'),
      ),
      summary: $summary.fromJson(
        data['summary'],
        name: DataCodec.childName(name, 'summary'),
      ),
      description: $description.fromJson(
        data['description'],
        name: DataCodec.childName(name, 'description'),
      ),
      externalDocs: $externalDocs.fromJson(
        data['externalDocs'],
        name: DataCodec.childName(name, 'externalDocs'),
      ),
      operationId: $operationId.fromJson(
        data['operationId'],
        name: DataCodec.childName(name, 'operationId'),
      ),
      consumes: $consumes.fromJson(
        data['consumes'],
        name: DataCodec.childName(name, 'consumes'),
      ),
      produces: $produces.fromJson(
        data['produces'],
        name: DataCodec.childName(name, 'produces'),
      ),
      responses: $responses.fromJson(
        data['responses'],
        name: DataCodec.childName(name, 'responses'),
      ),
      schemes: $schemes.fromJson(
        data['schemes'],
        name: DataCodec.childName(name, 'schemes'),
      ),
      deprecated: $deprecated.fromJson(
        data['deprecated'],
        name: DataCodec.childName(name, 'deprecated'),
      ),
      security: $security.fromJson(
        data['security'],
        name: DataCodec.childName(name, 'security'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as OperationObject;
    return {
      'tags': $tags.toJson($$data.tags),
      'summary': $summary.toJson($$data.summary),
      'description': $description.toJson($$data.description),
      'externalDocs': $externalDocs.toJson($$data.externalDocs),
      'operationId': $operationId.toJson($$data.operationId),
      'consumes': $consumes.toJson($$data.consumes),
      'produces': $produces.toJson($$data.produces),
      'responses': $responses.toJson($$data.responses),
      'schemes': $schemes.toJson($$data.schemes),
      'deprecated': $deprecated.toJson($$data.deprecated),
      'security': $security.toJson($$data.security),
    }..removeWhere((k, v) => v == null);
  }
}
