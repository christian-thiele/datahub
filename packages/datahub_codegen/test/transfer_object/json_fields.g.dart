// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_fields.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension JsonFieldsCopyExtension on JsonFields {
  JsonFields copyWith({
    List<dynamic>? dynamicList,
    List<dynamic>? dynamicListNullable,
    bool nullDynamicListNullable = false,
    List<String>? typedList,
    List<String>? typedListNullable,
    bool nullTypedListNullable = false,
    Map<String, dynamic>? dynamicMap,
    Map<String, dynamic>? dynamicMapNullable,
    bool nullDynamicMapNullable = false,
    Map<String, String>? typedMap,
    Map<String, String>? typedMapNullable,
    bool nullTypedMapNullable = false,
  }) {
    return JsonFields(
      dynamicList: dynamicList ?? this.dynamicList,
      dynamicListNullable: nullDynamicListNullable
          ? null
          : (dynamicListNullable ?? this.dynamicListNullable),
      typedList: typedList ?? this.typedList,
      typedListNullable: nullTypedListNullable
          ? null
          : (typedListNullable ?? this.typedListNullable),
      dynamicMap: dynamicMap ?? this.dynamicMap,
      dynamicMapNullable: nullDynamicMapNullable
          ? null
          : (dynamicMapNullable ?? this.dynamicMapNullable),
      typedMap: typedMap ?? this.typedMap,
      typedMapNullable: nullTypedMapNullable
          ? null
          : (typedMapNullable ?? this.typedMapNullable),
    );
  }
}

// **************************************************************************
// TransferBeanGenerator
// **************************************************************************

// ignore_for_file: constant_identifier_names

final JsonFieldsTransferBean = _JsonFieldsTransferBeanImpl._();

class _JsonFieldsTransferBeanImpl extends TransferBean<JsonFields> {
  _JsonFieldsTransferBeanImpl._();

  @override
  Map<String, dynamic> toMap(JsonFields transferObject) {
    return {
      'dynamicList':
          encodeListTyped<List<dynamic>, dynamic>(transferObject.dynamicList),
      'dynamicListNullable': encodeListTyped<List<dynamic>?, dynamic>(
          transferObject.dynamicListNullable),
      'typedList':
          encodeListTyped<List<String>, String>(transferObject.typedList),
      'typedListNullable': encodeListTyped<List<String>?, String>(
          transferObject.typedListNullable),
      'dynamicMap': encodeMapTyped<Map<String, dynamic>, dynamic>(
          transferObject.dynamicMap),
      'dynamicMapNullable': encodeMapTyped<Map<String, dynamic>?, dynamic>(
          transferObject.dynamicMapNullable),
      'typedMap':
          encodeMapTyped<Map<String, String>, String>(transferObject.typedMap),
      'typedMapNullable': encodeMapTyped<Map<String, String>?, String>(
          transferObject.typedMapNullable),
    }..removeWhere((k, v) => v == null);
  }

  @override
  JsonFields toObject(Map<String, dynamic> data, {String? name}) {
    return JsonFields(
      dynamicList: decodeListTyped<List<dynamic>, dynamic>(data['dynamicList'],
          name: name == null ? 'dynamicList' : '$name.dynamicList'),
      dynamicListNullable: decodeListTyped<List<dynamic>?, dynamic>(
          data['dynamicListNullable'],
          name: name == null
              ? 'dynamicListNullable'
              : '$name.dynamicListNullable'),
      typedList: decodeListTyped<List<String>, String>(data['typedList'],
          name: name == null ? 'typedList' : '$name.typedList'),
      typedListNullable: decodeListTyped<List<String>?, String>(
          data['typedListNullable'],
          name: name == null ? 'typedListNullable' : '$name.typedListNullable'),
      dynamicMap: decodeMapTyped<Map<String, dynamic>, dynamic>(
          data['dynamicMap'],
          name: name == null ? 'dynamicMap' : '$name.dynamicMap'),
      dynamicMapNullable: decodeMapTyped<Map<String, dynamic>?, dynamic>(
          data['dynamicMapNullable'],
          name:
              name == null ? 'dynamicMapNullable' : '$name.dynamicMapNullable'),
      typedMap: decodeMapTyped<Map<String, String>, String>(data['typedMap'],
          name: name == null ? 'typedMap' : '$name.typedMap'),
      typedMapNullable: decodeMapTyped<Map<String, String>?, String>(
          data['typedMapNullable'],
          name: name == null ? 'typedMapNullable' : '$name.typedMapNullable'),
    );
  }
}

// **************************************************************************
// TransferSuperclassGenerator
// **************************************************************************

abstract class _TransferObject extends TransferObjectBase<void> {
  @override
  dynamic toJson() => JsonFieldsTransferBean.toMap(this as JsonFields);

  @override
  TransferBean<JsonFields> get bean => JsonFieldsTransferBean;

  @override
  void getId() {}
}
