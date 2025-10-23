// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_object.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $SwaggerObject with DataObject<SwaggerObject> {
  const $SwaggerObject();
  static const $$codec = JsonDataCodec();
  static final $swagger = DataField<SwaggerObject, String>(
    name: 'swagger',
    valueOf: (p) => p.swagger,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $info = DataField<SwaggerObject, InfoObject>(
    name: 'info',
    valueOf: (p) => p.info,
    dataBean: () => $InfoObject.bean,
    fromJson: (value, {String? name}) =>
        $InfoObject.bean.fromJson(value, name: name),
    toJson: (value) => value.toJson(),
  );

  static final $host = DataField<SwaggerObject, String?>(
    name: 'host',
    valueOf: (p) => p.host,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $basePath = DataField<SwaggerObject, String?>(
    name: 'basePath',
    valueOf: (p) => p.basePath,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $schemes = DataField<SwaggerObject, List<String>>(
    name: 'schemes',
    valueOf: (p) => p.schemes,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $consumes = DataField<SwaggerObject, List<String>>(
    name: 'consumes',
    valueOf: (p) => p.consumes,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $produces = DataField<SwaggerObject, List<String>>(
    name: 'produces',
    valueOf: (p) => p.produces,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $paths = DataField<SwaggerObject, Map<String, PathItemObject>>(
    name: 'paths',
    valueOf: (p) => p.paths,
    dataBean: () => $PathItemObject.bean,
    fromJson: (value, {String? name}) => $$codec.decodeMap<PathItemObject>(
      value,
      $PathItemObject.bean.fromJson,
      name: name,
    ),
    toJson: (value) =>
        $$codec.encodeMap<PathItemObject>(value, (v) => v.toJson()),
  );

  static final $definitions = DataField<SwaggerObject, Map<String, dynamic>>(
    name: 'definitions',
    valueOf: (p) => p.definitions,
    fromJson: (value, {String? name}) => $$codec.decodeMap<dynamic>(
      (value ?? const {}),
      $$codec.decodeDynamic,
      name: name,
    ),
    toJson: (value) => $$codec.encodeMap<dynamic>(value, $$codec.encodeDynamic),
  );

  static final $security = DataField<SwaggerObject, List<dynamic>>(
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

  static final $tags = DataField<SwaggerObject, List<TagObject>>(
    name: 'tags',
    valueOf: (p) => p.tags,
    dataBean: () => $TagObject.bean,
    fromJson: (value, {String? name}) => $$codec.decodeList<TagObject>(
      (value ?? const []),
      $TagObject.bean.fromJson,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<TagObject>(value, (v) => v.toJson()),
  );

  static final $externalDocs =
      DataField<SwaggerObject, List<ExternalDocumentationObject>>(
        name: 'externalDocs',
        valueOf: (p) => p.externalDocs,
        dataBean: () => $ExternalDocumentationObject.bean,
        fromJson: (value, {String? name}) =>
            $$codec.decodeList<ExternalDocumentationObject>(
              (value ?? const []),
              $ExternalDocumentationObject.bean.fromJson,
              name: name,
            ),
        toJson: (value) => $$codec.encodeList<ExternalDocumentationObject>(
          value,
          (v) => v.toJson(),
        ),
      );

  static final DataBean<SwaggerObject> bean = DataBean<SwaggerObject>(
    name: 'SwaggerObject',
    fields: List<DataField<SwaggerObject, dynamic>>.unmodifiable([
      $swagger,
      $info,
      $host,
      $basePath,
      $schemes,
      $consumes,
      $produces,
      $paths,
      $definitions,
      $security,
      $tags,
      $externalDocs,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<SwaggerObject, dynamic>> get $$fields => bean.fields;
  SwaggerObject copyWith({
    String? swagger,
    InfoObject? info,
    String? host,
    bool nullHost = false,
    String? basePath,
    bool nullBasePath = false,
    List<String>? schemes,
    List<String>? consumes,
    List<String>? produces,
    Map<String, PathItemObject>? paths,
    Map<String, dynamic>? definitions,
    List<dynamic>? security,
    List<TagObject>? tags,
    List<ExternalDocumentationObject>? externalDocs,
  }) {
    final $data = this as SwaggerObject;
    return SwaggerObject(
      swagger: swagger ?? $data.swagger,
      info: info ?? $data.info,
      host: nullHost ? null : (host ?? $data.host),
      basePath: nullBasePath ? null : (basePath ?? $data.basePath),
      schemes: schemes ?? $data.schemes,
      consumes: consumes ?? $data.consumes,
      produces: produces ?? $data.produces,
      paths: paths ?? $data.paths,
      definitions: definitions ?? $data.definitions,
      security: security ?? $data.security,
      tags: tags ?? $data.tags,
      externalDocs: externalDocs ?? $data.externalDocs,
    );
  }

  static SwaggerObject fromValues(Map<String, dynamic> data) {
    return SwaggerObject(
      swagger: data['swagger'],
      info: data['info'],
      host: data['host'],
      basePath: data['basePath'],
      schemes: data['schemes'] ?? const [],
      consumes: data['consumes'] ?? const [],
      produces: data['produces'] ?? const [],
      paths: data['paths'],
      definitions: data['definitions'] ?? const {},
      security: data['security'] ?? const [],
      tags: data['tags'] ?? const [],
      externalDocs: data['externalDocs'] ?? const [],
    );
  }

  static SwaggerObject fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(SwaggerObject, data.runtimeType, name);
    }
    return SwaggerObject(
      swagger: $swagger.fromJson(
        data['swagger'],
        name: DataCodec.childName(name, 'swagger'),
      ),
      info: $info.fromJson(
        data['info'],
        name: DataCodec.childName(name, 'info'),
      ),
      host: $host.fromJson(
        data['host'],
        name: DataCodec.childName(name, 'host'),
      ),
      basePath: $basePath.fromJson(
        data['basePath'],
        name: DataCodec.childName(name, 'basePath'),
      ),
      schemes: $schemes.fromJson(
        data['schemes'],
        name: DataCodec.childName(name, 'schemes'),
      ),
      consumes: $consumes.fromJson(
        data['consumes'],
        name: DataCodec.childName(name, 'consumes'),
      ),
      produces: $produces.fromJson(
        data['produces'],
        name: DataCodec.childName(name, 'produces'),
      ),
      paths: $paths.fromJson(
        data['paths'],
        name: DataCodec.childName(name, 'paths'),
      ),
      definitions: $definitions.fromJson(
        data['definitions'],
        name: DataCodec.childName(name, 'definitions'),
      ),
      security: $security.fromJson(
        data['security'],
        name: DataCodec.childName(name, 'security'),
      ),
      tags: $tags.fromJson(
        data['tags'],
        name: DataCodec.childName(name, 'tags'),
      ),
      externalDocs: $externalDocs.fromJson(
        data['externalDocs'],
        name: DataCodec.childName(name, 'externalDocs'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as SwaggerObject;
    return {
      'swagger': $swagger.toJson($$data.swagger),
      'info': $info.toJson($$data.info),
      'host': $host.toJson($$data.host),
      'basePath': $basePath.toJson($$data.basePath),
      'schemes': $schemes.toJson($$data.schemes),
      'consumes': $consumes.toJson($$data.consumes),
      'produces': $produces.toJson($$data.produces),
      'paths': $paths.toJson($$data.paths),
      'definitions': $definitions.toJson($$data.definitions),
      'security': $security.toJson($$data.security),
      'tags': $tags.toJson($$data.tags),
      'externalDocs': $externalDocs.toJson($$data.externalDocs),
    }..removeWhere((k, v) => v == null);
  }
}
