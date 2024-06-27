// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension NotificationCopyExtension on Notification {
  Notification copyWith({
    String? title,
    String? text,
    bool? receive,
  }) {
    return Notification(
      title ?? this.title,
      text ?? this.text,
      receive ?? this.receive,
    );
  }
}

// **************************************************************************
// TransferBeanGenerator
// **************************************************************************

// ignore_for_file: constant_identifier_names

final NotificationTransferBean = _NotificationTransferBeanImpl._();

class _NotificationTransferBeanImpl extends TransferBean<Notification> {
  _NotificationTransferBeanImpl._();

  @override
  Map<String, dynamic> toMap(Notification transferObject) {
    return {
      'title': encodeTyped<String>(transferObject.title),
      'text': encodeTyped<String>(transferObject.text),
      'receive': encodeTyped<bool>(transferObject.receive),
    }..removeWhere((k, v) => v == null);
  }

  @override
  Notification toObject(Map<String, dynamic> data, {String? name}) {
    return Notification(
      decodeTyped<String>(data['title'],
          name: name == null ? 'title' : '$name.title'),
      decodeTyped<String>(data['text'],
          name: name == null ? 'text' : '$name.text'),
      decodeTyped<bool>(data['receive'],
          name: name == null ? 'receive' : '$name.receive'),
    );
  }
}

// **************************************************************************
// TransferSuperclassGenerator
// **************************************************************************

abstract class _TransferObject extends TransferObjectBase<void> {
  @override
  dynamic toJson() => NotificationTransferBean.toMap(this as Notification);

  @override
  TransferBean<Notification> get bean => NotificationTransferBean;

  @override
  void getId() {}
}
