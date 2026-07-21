// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arrays_data.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ArraysData with DataObject<ArraysData> {
  const $ArraysData();
  static const $$codec = JsonDataCodec();
  static final $stringArray = DataField<ArraysData, List<String>>(
    name: 'stringArray',
    valueOf: (p) => p.stringArray,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $intArray = DataField<ArraysData, List<int>>(
    name: 'intArray',
    valueOf: (p) => p.intArray,
    fromJson: (value, {String? name}) => $$codec.decodeList<int>(
      (value ?? const []),
      $$codec.decodeInt,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<int>(value, $$codec.encodeInt),
  );

  static final $doubleArray = DataField<ArraysData, List<double>>(
    name: 'doubleArray',
    valueOf: (p) => p.doubleArray,
    fromJson: (value, {String? name}) => $$codec.decodeList<double>(
      (value ?? const []),
      $$codec.decodeDouble,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<double>(value, $$codec.encodeDouble),
  );

  static final $boolArray = DataField<ArraysData, List<bool>>(
    name: 'boolArray',
    valueOf: (p) => p.boolArray,
    fromJson: (value, {String? name}) => $$codec.decodeList<bool>(
      (value ?? const []),
      $$codec.decodeBool,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<bool>(value, $$codec.encodeBool),
  );

  static final $enumArray = DataField<ArraysData, List<ExampleEnum>>(
    name: 'enumArray',
    valueOf: (p) => p.enumArray,
    fromJson: (value, {String? name}) => $$codec.decodeList<ExampleEnum>(
      (value ?? const []),
      (v, {String? name}) =>
          $$codec.decodeEnum(v, ExampleEnum.values, name: name),
      name: name,
    ),
    toJson: (value) =>
        $$codec.encodeList<ExampleEnum>(value, $$codec.encodeEnum),
    constraints: [EnumConstraint(values: ExampleEnum.values)],
  );

  static final $jsonList = DataField<ArraysData, List<dynamic>>(
    name: 'jsonList',
    valueOf: (p) => p.jsonList,
    fromJson: (value, {String? name}) => $$codec.decodeList<dynamic>(
      (value ?? const []),
      $$codec.decodeDynamic,
      name: name,
    ),
    toJson: (value) =>
        $$codec.encodeList<dynamic>(value, $$codec.encodeDynamic),
  );

  static final $jsonMap = DataField<ArraysData, Map<String, dynamic>>(
    name: 'jsonMap',
    valueOf: (p) => p.jsonMap,
    fromJson: (value, {String? name}) => $$codec.decodeMap<dynamic>(
      (value ?? const {}),
      $$codec.decodeDynamic,
      name: name,
    ),
    toJson: (value) => $$codec.encodeMap<dynamic>(value, $$codec.encodeDynamic),
  );

  static final DataBean<ArraysData> bean = DataBean<ArraysData>(
    name: 'ArraysData',
    fields: List<DataField<ArraysData, dynamic>>.unmodifiable([
      $stringArray,
      $intArray,
      $doubleArray,
      $boolArray,
      $enumArray,
      $jsonList,
      $jsonMap,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ArraysData, dynamic>> get $$fields => bean.fields;
  ArraysData copyWith({
    List<String>? stringArray,
    List<int>? intArray,
    List<double>? doubleArray,
    List<bool>? boolArray,
    List<ExampleEnum>? enumArray,
    List<dynamic>? jsonList,
    Map<String, dynamic>? jsonMap,
  }) {
    final $data = this as ArraysData;
    return ArraysData(
      stringArray: stringArray ?? $data.stringArray,
      intArray: intArray ?? $data.intArray,
      doubleArray: doubleArray ?? $data.doubleArray,
      boolArray: boolArray ?? $data.boolArray,
      enumArray: enumArray ?? $data.enumArray,
      jsonList: jsonList ?? $data.jsonList,
      jsonMap: jsonMap ?? $data.jsonMap,
    );
  }

  static ArraysData fromValues(Map<String, dynamic> data) {
    return ArraysData(
      stringArray:
          data['stringArray']?.cast<String>().toList(growable: false) ??
          const [],
      intArray:
          data['intArray']?.cast<int>().toList(growable: false) ?? const [],
      doubleArray:
          data['doubleArray']?.cast<double>().toList(growable: false) ??
          const [],
      boolArray:
          data['boolArray']?.cast<bool>().toList(growable: false) ?? const [],
      enumArray:
          data['enumArray']?.cast<ExampleEnum>().toList(growable: false) ??
          const [],
      jsonList:
          data['jsonList']?.cast<dynamic>().toList(growable: false) ?? const [],
      jsonMap: data['jsonMap'] ?? const {},
    );
  }

  static ArraysData fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ArraysData, data.runtimeType, name);
    }
    return ArraysData(
      stringArray: $stringArray.fromJson(
        data['stringArray'],
        name: DataCodec.childName(name, 'stringArray'),
      ),
      intArray: $intArray.fromJson(
        data['intArray'],
        name: DataCodec.childName(name, 'intArray'),
      ),
      doubleArray: $doubleArray.fromJson(
        data['doubleArray'],
        name: DataCodec.childName(name, 'doubleArray'),
      ),
      boolArray: $boolArray.fromJson(
        data['boolArray'],
        name: DataCodec.childName(name, 'boolArray'),
      ),
      enumArray: $enumArray.fromJson(
        data['enumArray'],
        name: DataCodec.childName(name, 'enumArray'),
      ),
      jsonList: $jsonList.fromJson(
        data['jsonList'],
        name: DataCodec.childName(name, 'jsonList'),
      ),
      jsonMap: $jsonMap.fromJson(
        data['jsonMap'],
        name: DataCodec.childName(name, 'jsonMap'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ArraysData;
    return {
      'stringArray': $stringArray.toJson($$data.stringArray),
      'intArray': $intArray.toJson($$data.intArray),
      'doubleArray': $doubleArray.toJson($$data.doubleArray),
      'boolArray': $boolArray.toJson($$data.boolArray),
      'enumArray': $enumArray.toJson($$data.enumArray),
      'jsonList': $jsonList.toJson($$data.jsonList),
      'jsonMap': $jsonMap.toJson($$data.jsonMap),
    }..removeWhere((k, v) => v == null);
  }
}
