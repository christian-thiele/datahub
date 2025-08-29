// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_dto.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension SimpleDtoCopyExtension on SimpleDto {
  SimpleDto copyWith({
    String? text,
    int? number,
  }) {
    return SimpleDto(
      text: text ?? this.text,
      number: number ?? this.number,
    );
  }
}

// **************************************************************************
// TransferBeanGenerator
// **************************************************************************

// ignore_for_file: constant_identifier_names

final SimpleDtoTransferBean = _SimpleDtoTransferBeanImpl._();

class _SimpleDtoTransferBeanImpl extends TransferBean<SimpleDto> {
  _SimpleDtoTransferBeanImpl._();

  @override
  Map<String, dynamic> toMap(SimpleDto transferObject) {
    return {
      'text': encodeTyped<String>(transferObject.text),
      'number': encodeTyped<int>(transferObject.number),
    }..removeWhere((k, v) => v == null);
  }

  @override
  SimpleDto toObject(Map<String, dynamic> data, {String? name}) {
    return SimpleDto(
      text: decodeTyped<String>(data['text'],
          name: name == null ? 'text' : '$name.text'),
      number: decodeTyped<int>(data['number'],
          name: name == null ? 'number' : '$name.number'),
    );
  }
}

// **************************************************************************
// TransferSuperclassGenerator
// **************************************************************************

abstract class _TransferObject extends TransferObjectBase<void> {
  @override
  dynamic toJson() => SimpleDtoTransferBean.toMap(this as SimpleDto);

  @override
  TransferBean<SimpleDto> get bean => SimpleDtoTransferBean;

  @override
  void getId() {}
}
