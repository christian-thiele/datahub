// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension ContactCopyExtension on Contact {
  Contact copyWith({
    String? id,
    String? name,
    String? number,
    String? address,
    List<int>? intList,
    List<JsonFields>? jsonFieldList,
    ContactType? type,
    List<ContactType>? enumList,
  }) {
    return Contact(
      id ?? this.id,
      name ?? this.name,
      number ?? this.number,
      address ?? this.address,
      intList ?? this.intList,
      jsonFieldList ?? this.jsonFieldList,
      type ?? this.type,
      enumList ?? this.enumList,
    );
  }
}

// **************************************************************************
// TransferBeanGenerator
// **************************************************************************

// ignore_for_file: constant_identifier_names

final ContactTransferBean = _ContactTransferBeanImpl._();

class _ContactTransferBeanImpl extends TransferBean<Contact> {
  _ContactTransferBeanImpl._();

  @override
  Map<String, dynamic> toMap(Contact transferObject) {
    return {
      'id': encodeTyped<String>(transferObject.id),
      'name': encodeTyped<String>(transferObject.name),
      'number': encodeTyped<String>(transferObject.number),
      'address': encodeTyped<String>(transferObject.address),
      'intList': encodeListTyped<List<int>, int>(transferObject.intList),
      'jsonFieldList': encodeList<List<JsonFields>, JsonFields>(
          transferObject.jsonFieldList, (v) => v.toJson()),
      'type': transferObject.type.name,
      'enumList': encodeList<List<ContactType>, ContactType>(
          transferObject.enumList, (v) => v.name),
    }..removeWhere((k, v) => v == null);
  }

  @override
  Contact toObject(Map<String, dynamic> data, {String? name}) {
    return Contact(
      decodeTyped<String>(data['id'], name: name == null ? 'id' : '$name.id'),
      decodeTyped<String>(data['name'],
          name: name == null ? 'name' : '$name.name'),
      decodeTyped<String>(data['number'],
          name: name == null ? 'number' : '$name.number'),
      decodeTyped<String>(data['address'],
          name: name == null ? 'address' : '$name.address'),
      decodeListTyped<List<int>, int>(data['intList'],
          name: name == null ? 'intList' : '$name.intList'),
      decodeList<List<JsonFields>, JsonFields>(data['jsonFieldList'],
          (v, n) => JsonFieldsTransferBean.toObject(v, name: n),
          name: name == null ? 'jsonFieldList' : '$name.jsonFieldList'),
      decodeEnum(data['type'], ContactType.values,
          name: name == null ? 'type' : '$name.type'),
      decodeList<List<ContactType>, ContactType>(data['enumList'],
          (v, n) => decodeEnum(v, ContactType.values, name: n),
          name: name == null ? 'enumList' : '$name.enumList'),
    );
  }
}

// **************************************************************************
// TransferSuperclassGenerator
// **************************************************************************

abstract class _TransferObject extends TransferObjectBase<String> {
  @override
  dynamic toJson() => ContactTransferBean.toMap(this as Contact);

  @override
  TransferBean<Contact> get bean => ContactTransferBean;

  @override
  String getId() => (this as Contact).id;
}
