// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placeholder_user.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension PlaceholderUserCopyExtension on PlaceholderUser {
  PlaceholderUser copyWith({
    String? id,
    String? name,
  }) {
    return PlaceholderUser(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

// **************************************************************************
// TransferBeanGenerator
// **************************************************************************

// ignore_for_file: constant_identifier_names

final PlaceholderUserTransferBean = _PlaceholderUserTransferBeanImpl._();

class _PlaceholderUserTransferBeanImpl extends TransferBean<PlaceholderUser> {
  _PlaceholderUserTransferBeanImpl._();

  @override
  Map<String, dynamic> toMap(PlaceholderUser transferObject) {
    return {
      'id': encodeTyped<String>(transferObject.id),
      'name': encodeTyped<String>(transferObject.name),
    }..removeWhere((k, v) => v == null);
  }

  @override
  PlaceholderUser toObject(Map<String, dynamic> data, {String? name}) {
    return PlaceholderUser(
      id: decodeTyped<String>(data['id'],
          name: name == null ? 'id' : '$name.id'),
      name: decodeTyped<String>(data['name'],
          name: name == null ? 'name' : '$name.name'),
    );
  }
}

// **************************************************************************
// TransferSuperclassGenerator
// **************************************************************************

abstract class _TransferObject extends TransferObjectBase<void> {
  @override
  dynamic toJson() =>
      PlaceholderUserTransferBean.toMap(this as PlaceholderUser);

  @override
  TransferBean<PlaceholderUser> get bean => PlaceholderUserTransferBean;

  @override
  void getId() {}
}
