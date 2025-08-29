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
    Contact? contact,
    Contact? contactNullable,
    bool nullContactNullable = false,
    List<Contact>? contacts,
    List<Contact>? contactsNullable,
    List<Contact>? contactsNullable2,
    bool nullContactsNullable2 = false,
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
      contact: contact ?? this.contact,
      contactNullable: nullContactNullable
          ? null
          : (contactNullable ?? this.contactNullable),
      contacts: contacts ?? this.contacts,
      contactsNullable: contactsNullable ?? this.contactsNullable,
      contactsNullable2: nullContactsNullable2
          ? null
          : (contactsNullable2 ?? this.contactsNullable2),
    );
  }
}

// **************************************************************************
// DataBeanGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names

final JsonFieldsDataBean = _JsonFieldsDataBeanImpl._();

class _JsonFieldsDataBeanImpl extends DataBean<JsonFields> {
  @override
  final layoutName = 'json_fields';

  _JsonFieldsDataBeanImpl._();

  final dynamicList = DataField<JsonListDataType>(
    layoutName: 'json_fields',
    name: 'dynamic_list',
    nullable: false,
    length: 0,
  );

  final dynamicListNullable = DataField<JsonListDataType>(
    layoutName: 'json_fields',
    name: 'dynamic_list_nullable',
    nullable: true,
    length: 0,
  );

  final typedList = DataField<StringArrayDataType>(
    layoutName: 'json_fields',
    name: 'typed_list',
    nullable: false,
    length: 0,
  );

  final typedListNullable = DataField<StringArrayDataType>(
    layoutName: 'json_fields',
    name: 'typed_list_nullable',
    nullable: true,
    length: 0,
  );

  final dynamicMap = DataField<JsonMapDataType>(
    layoutName: 'json_fields',
    name: 'dynamic_map',
    nullable: false,
    length: 0,
  );

  final dynamicMapNullable = DataField<JsonMapDataType>(
    layoutName: 'json_fields',
    name: 'dynamic_map_nullable',
    nullable: true,
    length: 0,
  );

  final typedMap = DataField<JsonMapDataType>(
    layoutName: 'json_fields',
    name: 'typed_map',
    nullable: false,
    length: 0,
  );

  final typedMapNullable = DataField<JsonMapDataType>(
    layoutName: 'json_fields',
    name: 'typed_map_nullable',
    nullable: true,
    length: 0,
  );

  final contact = DataField<JsonMapDataType>(
    layoutName: 'json_fields',
    name: 'contact',
    nullable: false,
    length: 0,
  );

  final contactNullable = DataField<JsonMapDataType>(
    layoutName: 'json_fields',
    name: 'contact_nullable',
    nullable: true,
    length: 0,
  );

  final contacts = DataField<JsonListDataType>(
    layoutName: 'json_fields',
    name: 'contacts',
    nullable: false,
    length: 0,
  );

  final contactsNullable = DataField<JsonListDataType>(
    layoutName: 'json_fields',
    name: 'contacts_nullable',
    nullable: false,
    length: 0,
  );

  final contactsNullable2 = DataField<JsonListDataType>(
    layoutName: 'json_fields',
    name: 'contacts_nullable2',
    nullable: true,
    length: 0,
  );

  @override
  late final fields = [
    dynamicList,
    dynamicListNullable,
    typedList,
    typedListNullable,
    dynamicMap,
    dynamicMapNullable,
    typedMap,
    typedMapNullable,
    contact,
    contactNullable,
    contacts,
    contactsNullable,
    contactsNullable2,
  ];

  @override
  late final reactivePartitions = [];

  @override
  Map<DataField, dynamic> unmap(JsonFields dao,
      {bool includePrimaryKey = false}) {
    return {
      dynamicList: dao.dynamicList,
      dynamicListNullable: dao.dynamicListNullable,
      typedList: dao.typedList,
      typedListNullable: dao.typedListNullable,
      dynamicMap: dao.dynamicMap,
      dynamicMapNullable: dao.dynamicMapNullable,
      typedMap: dao.typedMap,
      typedMapNullable: dao.typedMapNullable,
      contact: dao.contact.toJson(),
      contactNullable: dao.contactNullable?.toJson(),
      contacts:
          encodeList<List<Contact>, Contact>(dao.contacts, (v) => v.toJson()),
      contactsNullable: encodeList<List<Contact?>, Contact?>(
          dao.contactsNullable, (v) => v?.toJson()),
      contactsNullable2: encodeList<List<Contact>?, Contact>(
          dao.contactsNullable2, (v) => v.toJson()),
    };
  }

  @override
  JsonFields mapValues(Map<String, dynamic> data) {
    return JsonFields(
      dynamicList:
          decodeListTyped<List<dynamic>, dynamic>(data['dynamic_list']),
      dynamicListNullable: decodeListTyped<List<dynamic>?, dynamic>(
          data['dynamic_list_nullable']),
      typedList: decodeListTyped<List<String>, String>(data['typed_list']),
      typedListNullable:
          decodeListTyped<List<String>?, String>(data['typed_list_nullable']),
      dynamicMap:
          decodeMapTyped<Map<String, dynamic>, dynamic>(data['dynamic_map']),
      dynamicMapNullable: decodeMapTyped<Map<String, dynamic>?, dynamic>(
          data['dynamic_map_nullable']),
      typedMap: decodeMapTyped<Map<String, String>, String>(data['typed_map']),
      typedMapNullable: decodeMapTyped<Map<String, String>?, String>(
          data['typed_map_nullable']),
      contact: ContactTransferBean.toObject(data['contact'], name: 'contact'),
      contactNullable: data['contact_nullable'] != null
          ? ContactTransferBean.toObject(data['contact_nullable'],
              name: 'contactNullable')
          : null,
      contacts: decodeList<List<Contact>, Contact>(
          data['contacts'], (v, n) => ContactTransferBean.toObject(v, name: n)),
      contactsNullable: decodeList<List<Contact?>, Contact?>(
          data['contacts_nullable'],
          (v, n) => data['contacts_nullable'] != null
              ? ContactTransferBean.toObject(v, name: n)
              : null),
      contactsNullable2: decodeList<List<Contact>?, Contact>(
          data['contacts_nullable2'],
          (v, n) => ContactTransferBean.toObject(v, name: n)),
    );
  }
}

// **************************************************************************
// DataSuperclassGenerator
// **************************************************************************

abstract class _Dao extends BaseDao<JsonFields> {
  @override
  _JsonFieldsDataBeanImpl get bean => JsonFieldsDataBean;
}
