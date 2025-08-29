// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empty.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension EmptyCopyExtension on Empty {
  Empty copyWith() {
    return Empty();
  }
}

// **************************************************************************
// TransferBeanGenerator
// **************************************************************************

// ignore_for_file: constant_identifier_names

final EmptyTransferBean = _EmptyTransferBeanImpl._();

class _EmptyTransferBeanImpl extends TransferBean<Empty> {
  _EmptyTransferBeanImpl._();

  @override
  Map<String, dynamic> toMap(Empty transferObject) {
    return {}..removeWhere((k, v) => v == null);
  }

  @override
  Empty toObject(Map<String, dynamic> data, {String? name}) {
    return Empty();
  }
}

// **************************************************************************
// TransferSuperclassGenerator
// **************************************************************************

abstract class _TransferObject extends TransferObjectBase<void> {
  @override
  dynamic toJson() => EmptyTransferBean.toMap(this as Empty);

  @override
  TransferBean<Empty> get bean => EmptyTransferBean;

  @override
  void getId() {}
}
