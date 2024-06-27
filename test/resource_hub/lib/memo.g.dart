// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension MemoCopyExtension on Memo {
  Memo copyWith({
    int? id,
    String? text,
    DateTime? timestamp,
  }) {
    return Memo(
      id ?? this.id,
      text ?? this.text,
      timestamp ?? this.timestamp,
    );
  }
}

// **************************************************************************
// TransferBeanGenerator
// **************************************************************************

// ignore_for_file: constant_identifier_names

const MemoTransferBean = _MemoTransferBeanImpl._();

class _MemoTransferBeanImpl extends TransferBean<Memo> {
  const _MemoTransferBeanImpl._();

  @override
  Map<String, dynamic> toMap(Memo transferObject) {
    return {
      'id': encodeTyped<int>(transferObject.id),
      'text': encodeTyped<String>(transferObject.text),
      'timestamp': encodeTyped<DateTime>(transferObject.timestamp),
    }..removeWhere((k, v) => v == null);
  }

  @override
  Memo toObject(Map<String, dynamic> data, {String? name}) {
    return Memo(
      decodeTyped<int>(data['id'], name: name == null ? 'id' : '$name.id'),
      decodeTyped<String>(data['text'],
          name: name == null ? 'text' : '$name.text'),
      decodeTyped<DateTime>(data['timestamp'],
          name: name == null ? 'timestamp' : '$name.timestamp'),
    );
  }
}

// **************************************************************************
// TransferSuperclassGenerator
// **************************************************************************

abstract class _TransferObject extends TransferObjectBase<int> {
  @override
  dynamic toJson() => MemoTransferBean.toMap(this as Memo);

  @override
  TransferBean<Memo> get bean => MemoTransferBean;

  @override
  int getId() => (this as Memo).id;
}
