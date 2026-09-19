// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'large.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Large with DataObject<Large> {
  const $Large();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Large, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true)],
  );

  static final $intProperty = DataField<Large, int>(
    name: 'intProperty',
    valueOf: (p) => p.intProperty,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $intListProperty = DataField<Large, List<int>>(
    name: 'intListProperty',
    valueOf: (p) => p.intListProperty,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<int>(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeList<int>(value, $$codec.encodeInt),
  );

  static final $doubleProperty = DataField<Large, double>(
    name: 'doubleProperty',
    valueOf: (p) => p.doubleProperty,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
  );

  static final $doubleListProperty = DataField<Large, List<double>>(
    name: 'doubleListProperty',
    valueOf: (p) => p.doubleListProperty,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<double>(value, $$codec.decodeDouble, name: name),
    toJson: (value) => $$codec.encodeList<double>(value, $$codec.encodeDouble),
  );

  static final $stringProperty = DataField<Large, String>(
    name: 'stringProperty',
    valueOf: (p) => p.stringProperty,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $stringListProperty = DataField<Large, List<String>>(
    name: 'stringListProperty',
    valueOf: (p) => p.stringListProperty,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $boolProperty = DataField<Large, bool>(
    name: 'boolProperty',
    valueOf: (p) => p.boolProperty,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $boolListProperty = DataField<Large, List<bool>>(
    name: 'boolListProperty',
    valueOf: (p) => p.boolListProperty,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<bool>(value, $$codec.decodeBool, name: name),
    toJson: (value) => $$codec.encodeList<bool>(value, $$codec.encodeBool),
  );

  static final $enumProperty = DataField<Large, EnumExample>(
    name: 'enumProperty',
    valueOf: (p) => p.enumProperty,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, EnumExample.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: EnumExample.values)],
  );

  static final $enumListProperty = DataField<Large, List<EnumExample>>(
    name: 'enumListProperty',
    valueOf: (p) => p.enumListProperty,
    fromJson: (value, {String? name}) => $$codec.decodeList<EnumExample>(
      value,
      (v, {String? name}) =>
          $$codec.decodeEnum(v, EnumExample.values, name: name),
      name: name,
    ),
    toJson: (value) =>
        $$codec.encodeList<EnumExample>(value, $$codec.encodeEnum),
    constraints: [
      ElementConstraint(constraint: EnumConstraint(values: EnumExample.values)),
    ],
  );

  static final $jsonProperty = DataField<Large, Map<String, dynamic>>(
    name: 'jsonProperty',
    valueOf: (p) => p.jsonProperty,
    fromJson: (value, {String? name}) =>
        $$codec.decodeMap<dynamic>(value, $$codec.decodeDynamic, name: name),
    toJson: (value) => $$codec.encodeMap<dynamic>(value, $$codec.encodeDynamic),
  );

  static final $jsonListProperty = DataField<Large, List<dynamic>>(
    name: 'jsonListProperty',
    valueOf: (p) => p.jsonListProperty,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<dynamic>(value, $$codec.decodeDynamic, name: name),
    toJson: (value) =>
        $$codec.encodeList<dynamic>(value, $$codec.encodeDynamic),
  );

  static final DataBean<Large> bean = DataBean<Large>(
    name: 'Large',
    fields: List<DataField<Large, dynamic>>.unmodifiable([
      $id,
      $intProperty,
      $intListProperty,
      $doubleProperty,
      $doubleListProperty,
      $stringProperty,
      $stringListProperty,
      $boolProperty,
      $boolListProperty,
      $enumProperty,
      $enumListProperty,
      $jsonProperty,
      $jsonListProperty,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Large, dynamic>> get $$fields => bean.fields;
  Large copyWith({
    int? id,
    int? intProperty,
    List<int>? intListProperty,
    double? doubleProperty,
    List<double>? doubleListProperty,
    String? stringProperty,
    List<String>? stringListProperty,
    bool? boolProperty,
    List<bool>? boolListProperty,
    EnumExample? enumProperty,
    List<EnumExample>? enumListProperty,
    Map<String, dynamic>? jsonProperty,
    List<dynamic>? jsonListProperty,
  }) {
    final $data = this as Large;
    return Large(
      id: id ?? $data.id,
      intProperty: intProperty ?? $data.intProperty,
      intListProperty: intListProperty ?? $data.intListProperty,
      doubleProperty: doubleProperty ?? $data.doubleProperty,
      doubleListProperty: doubleListProperty ?? $data.doubleListProperty,
      stringProperty: stringProperty ?? $data.stringProperty,
      stringListProperty: stringListProperty ?? $data.stringListProperty,
      boolProperty: boolProperty ?? $data.boolProperty,
      boolListProperty: boolListProperty ?? $data.boolListProperty,
      enumProperty: enumProperty ?? $data.enumProperty,
      enumListProperty: enumListProperty ?? $data.enumListProperty,
      jsonProperty: jsonProperty ?? $data.jsonProperty,
      jsonListProperty: jsonListProperty ?? $data.jsonListProperty,
    );
  }

  static Large fromValues(Map<String, dynamic> data) {
    return Large(
      id: data['id'] ?? 0,
      intProperty: data['intProperty'],
      intListProperty: data['intListProperty']?.cast<int>().toList(
        growable: false,
      ),
      doubleProperty: data['doubleProperty'],
      doubleListProperty: data['doubleListProperty']?.cast<double>().toList(
        growable: false,
      ),
      stringProperty: data['stringProperty'],
      stringListProperty: data['stringListProperty']?.cast<String>().toList(
        growable: false,
      ),
      boolProperty: data['boolProperty'],
      boolListProperty: data['boolListProperty']?.cast<bool>().toList(
        growable: false,
      ),
      enumProperty: data['enumProperty'],
      enumListProperty: data['enumListProperty']?.cast<EnumExample>().toList(
        growable: false,
      ),
      jsonProperty: data['jsonProperty'],
      jsonListProperty: data['jsonListProperty']?.cast<dynamic>().toList(
        growable: false,
      ),
    );
  }

  static Large fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Large, data.runtimeType, name);
    }
    return Large(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      intProperty: $intProperty.fromJson(
        data['intProperty'],
        name: DataCodec.childName(name, 'intProperty'),
      ),
      intListProperty: $intListProperty.fromJson(
        data['intListProperty'],
        name: DataCodec.childName(name, 'intListProperty'),
      ),
      doubleProperty: $doubleProperty.fromJson(
        data['doubleProperty'],
        name: DataCodec.childName(name, 'doubleProperty'),
      ),
      doubleListProperty: $doubleListProperty.fromJson(
        data['doubleListProperty'],
        name: DataCodec.childName(name, 'doubleListProperty'),
      ),
      stringProperty: $stringProperty.fromJson(
        data['stringProperty'],
        name: DataCodec.childName(name, 'stringProperty'),
      ),
      stringListProperty: $stringListProperty.fromJson(
        data['stringListProperty'],
        name: DataCodec.childName(name, 'stringListProperty'),
      ),
      boolProperty: $boolProperty.fromJson(
        data['boolProperty'],
        name: DataCodec.childName(name, 'boolProperty'),
      ),
      boolListProperty: $boolListProperty.fromJson(
        data['boolListProperty'],
        name: DataCodec.childName(name, 'boolListProperty'),
      ),
      enumProperty: $enumProperty.fromJson(
        data['enumProperty'],
        name: DataCodec.childName(name, 'enumProperty'),
      ),
      enumListProperty: $enumListProperty.fromJson(
        data['enumListProperty'],
        name: DataCodec.childName(name, 'enumListProperty'),
      ),
      jsonProperty: $jsonProperty.fromJson(
        data['jsonProperty'],
        name: DataCodec.childName(name, 'jsonProperty'),
      ),
      jsonListProperty: $jsonListProperty.fromJson(
        data['jsonListProperty'],
        name: DataCodec.childName(name, 'jsonListProperty'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Large;
    return {
      'id': $id.toJson($$data.id),
      'intProperty': $intProperty.toJson($$data.intProperty),
      'intListProperty': $intListProperty.toJson($$data.intListProperty),
      'doubleProperty': $doubleProperty.toJson($$data.doubleProperty),
      'doubleListProperty': $doubleListProperty.toJson(
        $$data.doubleListProperty,
      ),
      'stringProperty': $stringProperty.toJson($$data.stringProperty),
      'stringListProperty': $stringListProperty.toJson(
        $$data.stringListProperty,
      ),
      'boolProperty': $boolProperty.toJson($$data.boolProperty),
      'boolListProperty': $boolListProperty.toJson($$data.boolListProperty),
      'enumProperty': $enumProperty.toJson($$data.enumProperty),
      'enumListProperty': $enumListProperty.toJson($$data.enumListProperty),
      'jsonProperty': $jsonProperty.toJson($$data.jsonProperty),
      'jsonListProperty': $jsonListProperty.toJson($$data.jsonListProperty),
    }..removeWhere((k, v) => v == null);
  }
}
