// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_object.dart';

// **************************************************************************
// CopyWithExtensionGenerator
// **************************************************************************

extension ExampleObjectCopyExtension on ExampleObject {
  ExampleObject copyWith({
    Slideshow? slideshow,
  }) {
    return ExampleObject(
      slideshow ?? this.slideshow,
    );
  }
}

// **************************************************************************
// TransferBeanGenerator
// **************************************************************************

// ignore_for_file: constant_identifier_names

const ExampleObjectTransferBean = _ExampleObjectTransferBeanImpl._();

class _ExampleObjectTransferBeanImpl extends TransferBean<ExampleObject> {
  const _ExampleObjectTransferBeanImpl._();

  @override
  Map<String, dynamic> toMap(ExampleObject transferObject) {
    return {
      'slideshow': transferObject.slideshow.toJson(),
    }..removeWhere((k, v) => v == null);
  }

  @override
  ExampleObject toObject(Map<String, dynamic> data, {String? name}) {
    return ExampleObject(
      SlideshowTransferBean.toObject(data['slideshow'],
          name: name == null ? 'slideshow' : '$name.slideshow'),
    );
  }
}

// **************************************************************************
// TransferSuperclassGenerator
// **************************************************************************

abstract class _TransferObject extends TransferObjectBase<void> {
  @override
  dynamic toJson() => ExampleObjectTransferBean.toMap(this as ExampleObject);

  @override
  TransferBean<ExampleObject> get bean => ExampleObjectTransferBean;

  @override
  void getId() {}
}
