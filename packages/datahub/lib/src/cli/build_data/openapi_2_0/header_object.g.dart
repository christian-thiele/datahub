// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'header_object.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $HeaderObject with DataObject<HeaderObject> {
  const $HeaderObject();
  static const $$codec = JsonDataCodec();
  static final $description = DataField<HeaderObject, String?>(
    name: 'description',
    valueOf: (p) => p.description,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $type = DataField<HeaderObject, String>(
    name: 'type',
    valueOf: (p) => p.type,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $format = DataField<HeaderObject, String?>(
    name: 'format',
    valueOf: (p) => p.format,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $items = DataField<HeaderObject, Map<String, dynamic>?>(
    name: 'items',
    valueOf: (p) => p.items,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      (v, {String? name}) =>
          $$codec.decodeMap<dynamic>(v, $$codec.decodeDynamic, name: name),
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(
      value,
      (v) => $$codec.encodeMap<dynamic>(v, $$codec.encodeDynamic),
    ),
  );

  static final $collectionFormat = DataField<HeaderObject, String?>(
    name: 'collectionFormat',
    valueOf: (p) => p.collectionFormat,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $defaultValue = DataField<HeaderObject, dynamic>(
    name: 'defaultValue',
    valueOf: (p) => p.defaultValue,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDynamic(value, name: name),
    toJson: (value) => $$codec.encodeDynamic(value),
  );

  static final $maximum = DataField<HeaderObject, double?>(
    name: 'maximum',
    valueOf: (p) => p.maximum,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDouble, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDouble),
  );

  static final $exclusiveMaximum = DataField<HeaderObject, bool?>(
    name: 'exclusiveMaximum',
    valueOf: (p) => p.exclusiveMaximum,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeBool, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeBool),
  );

  static final $minimum = DataField<HeaderObject, double?>(
    name: 'minimum',
    valueOf: (p) => p.minimum,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDouble, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDouble),
  );

  static final $exclusiveMinimum = DataField<HeaderObject, bool?>(
    name: 'exclusiveMinimum',
    valueOf: (p) => p.exclusiveMinimum,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeBool, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeBool),
  );

  static final $maxLength = DataField<HeaderObject, int?>(
    name: 'maxLength',
    valueOf: (p) => p.maxLength,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $minLength = DataField<HeaderObject, int?>(
    name: 'minLength',
    valueOf: (p) => p.minLength,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $pattern = DataField<HeaderObject, String?>(
    name: 'pattern',
    valueOf: (p) => p.pattern,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $maxItems = DataField<HeaderObject, int?>(
    name: 'maxItems',
    valueOf: (p) => p.maxItems,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $minItems = DataField<HeaderObject, int?>(
    name: 'minItems',
    valueOf: (p) => p.minItems,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $uniqueItems = DataField<HeaderObject, bool?>(
    name: 'uniqueItems',
    valueOf: (p) => p.uniqueItems,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeBool, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeBool),
  );

  static final $enumValues = DataField<HeaderObject, List<dynamic>?>(
    name: 'enumValues',
    valueOf: (p) => p.enumValues,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      (v, {String? name}) =>
          $$codec.decodeList<dynamic>(v, $$codec.decodeDynamic, name: name),
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(
      value,
      (v) => $$codec.encodeList<dynamic>(v, $$codec.encodeDynamic),
    ),
  );

  static final $multipleOf = DataField<HeaderObject, double?>(
    name: 'multipleOf',
    valueOf: (p) => p.multipleOf,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDouble, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDouble),
  );

  static final DataBean<HeaderObject> bean = DataBean<HeaderObject>(
    name: 'HeaderObject',
    fields: List<DataField<HeaderObject, dynamic>>.unmodifiable([
      $description,
      $type,
      $format,
      $items,
      $collectionFormat,
      $defaultValue,
      $maximum,
      $exclusiveMaximum,
      $minimum,
      $exclusiveMinimum,
      $maxLength,
      $minLength,
      $pattern,
      $maxItems,
      $minItems,
      $uniqueItems,
      $enumValues,
      $multipleOf,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<HeaderObject, dynamic>> get $$fields => bean.fields;
  HeaderObject copyWith({
    String? description,
    bool nullDescription = false,
    String? type,
    String? format,
    bool nullFormat = false,
    Map<String, dynamic>? items,
    bool nullItems = false,
    String? collectionFormat,
    bool nullCollectionFormat = false,
    dynamic? defaultValue,
    double? maximum,
    bool nullMaximum = false,
    bool? exclusiveMaximum,
    bool nullExclusiveMaximum = false,
    double? minimum,
    bool nullMinimum = false,
    bool? exclusiveMinimum,
    bool nullExclusiveMinimum = false,
    int? maxLength,
    bool nullMaxLength = false,
    int? minLength,
    bool nullMinLength = false,
    String? pattern,
    bool nullPattern = false,
    int? maxItems,
    bool nullMaxItems = false,
    int? minItems,
    bool nullMinItems = false,
    bool? uniqueItems,
    bool nullUniqueItems = false,
    List<dynamic>? enumValues,
    bool nullEnumValues = false,
    double? multipleOf,
    bool nullMultipleOf = false,
  }) {
    final $data = this as HeaderObject;
    return HeaderObject(
      description: nullDescription ? null : (description ?? $data.description),
      type: type ?? $data.type,
      format: nullFormat ? null : (format ?? $data.format),
      items: nullItems ? null : (items ?? $data.items),
      collectionFormat: nullCollectionFormat
          ? null
          : (collectionFormat ?? $data.collectionFormat),
      defaultValue: defaultValue ?? $data.defaultValue,
      maximum: nullMaximum ? null : (maximum ?? $data.maximum),
      exclusiveMaximum: nullExclusiveMaximum
          ? null
          : (exclusiveMaximum ?? $data.exclusiveMaximum),
      minimum: nullMinimum ? null : (minimum ?? $data.minimum),
      exclusiveMinimum: nullExclusiveMinimum
          ? null
          : (exclusiveMinimum ?? $data.exclusiveMinimum),
      maxLength: nullMaxLength ? null : (maxLength ?? $data.maxLength),
      minLength: nullMinLength ? null : (minLength ?? $data.minLength),
      pattern: nullPattern ? null : (pattern ?? $data.pattern),
      maxItems: nullMaxItems ? null : (maxItems ?? $data.maxItems),
      minItems: nullMinItems ? null : (minItems ?? $data.minItems),
      uniqueItems: nullUniqueItems ? null : (uniqueItems ?? $data.uniqueItems),
      enumValues: nullEnumValues ? null : (enumValues ?? $data.enumValues),
      multipleOf: nullMultipleOf ? null : (multipleOf ?? $data.multipleOf),
    );
  }

  static HeaderObject fromValues(Map<String, dynamic> data) {
    return HeaderObject(
      description: data['description'],
      type: data['type'],
      format: data['format'],
      items: data['items'],
      collectionFormat: data['collectionFormat'],
      defaultValue: data['defaultValue'],
      maximum: data['maximum'],
      exclusiveMaximum: data['exclusiveMaximum'],
      minimum: data['minimum'],
      exclusiveMinimum: data['exclusiveMinimum'],
      maxLength: data['maxLength'],
      minLength: data['minLength'],
      pattern: data['pattern'],
      maxItems: data['maxItems'],
      minItems: data['minItems'],
      uniqueItems: data['uniqueItems'],
      enumValues: data['enumValues'],
      multipleOf: data['multipleOf'],
    );
  }

  static HeaderObject fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(HeaderObject, data.runtimeType, name);
    }
    return HeaderObject(
      description: $description.fromJson(
        data['description'],
        name: DataCodec.childName(name, 'description'),
      ),
      type: $type.fromJson(
        data['type'],
        name: DataCodec.childName(name, 'type'),
      ),
      format: $format.fromJson(
        data['format'],
        name: DataCodec.childName(name, 'format'),
      ),
      items: $items.fromJson(
        data['items'],
        name: DataCodec.childName(name, 'items'),
      ),
      collectionFormat: $collectionFormat.fromJson(
        data['collectionFormat'],
        name: DataCodec.childName(name, 'collectionFormat'),
      ),
      defaultValue: $defaultValue.fromJson(
        data['default'],
        name: DataCodec.childName(name, 'default'),
      ),
      maximum: $maximum.fromJson(
        data['maximum'],
        name: DataCodec.childName(name, 'maximum'),
      ),
      exclusiveMaximum: $exclusiveMaximum.fromJson(
        data['exclusiveMaximum'],
        name: DataCodec.childName(name, 'exclusiveMaximum'),
      ),
      minimum: $minimum.fromJson(
        data['minimum'],
        name: DataCodec.childName(name, 'minimum'),
      ),
      exclusiveMinimum: $exclusiveMinimum.fromJson(
        data['exclusiveMinimum'],
        name: DataCodec.childName(name, 'exclusiveMinimum'),
      ),
      maxLength: $maxLength.fromJson(
        data['maxLength'],
        name: DataCodec.childName(name, 'maxLength'),
      ),
      minLength: $minLength.fromJson(
        data['minLength'],
        name: DataCodec.childName(name, 'minLength'),
      ),
      pattern: $pattern.fromJson(
        data['pattern'],
        name: DataCodec.childName(name, 'pattern'),
      ),
      maxItems: $maxItems.fromJson(
        data['maxItems'],
        name: DataCodec.childName(name, 'maxItems'),
      ),
      minItems: $minItems.fromJson(
        data['minItems'],
        name: DataCodec.childName(name, 'minItems'),
      ),
      uniqueItems: $uniqueItems.fromJson(
        data['uniqueItems'],
        name: DataCodec.childName(name, 'uniqueItems'),
      ),
      enumValues: $enumValues.fromJson(
        data['enum'],
        name: DataCodec.childName(name, 'enum'),
      ),
      multipleOf: $multipleOf.fromJson(
        data['multipleOf'],
        name: DataCodec.childName(name, 'multipleOf'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as HeaderObject;
    return {
      'description': $description.toJson($$data.description),
      'type': $type.toJson($$data.type),
      'format': $format.toJson($$data.format),
      'items': $items.toJson($$data.items),
      'collectionFormat': $collectionFormat.toJson($$data.collectionFormat),
      'default': $defaultValue.toJson($$data.defaultValue),
      'maximum': $maximum.toJson($$data.maximum),
      'exclusiveMaximum': $exclusiveMaximum.toJson($$data.exclusiveMaximum),
      'minimum': $minimum.toJson($$data.minimum),
      'exclusiveMinimum': $exclusiveMinimum.toJson($$data.exclusiveMinimum),
      'maxLength': $maxLength.toJson($$data.maxLength),
      'minLength': $minLength.toJson($$data.minLength),
      'pattern': $pattern.toJson($$data.pattern),
      'maxItems': $maxItems.toJson($$data.maxItems),
      'minItems': $minItems.toJson($$data.minItems),
      'uniqueItems': $uniqueItems.toJson($$data.uniqueItems),
      'enum': $enumValues.toJson($$data.enumValues),
      'multipleOf': $multipleOf.toJson($$data.multipleOf),
    }..removeWhere((k, v) => v == null);
  }
}
